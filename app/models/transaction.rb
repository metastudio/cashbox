# == Schema Information
#
# Table name: transactions
#
#  id               :integer          not null, primary key
#  amount_cents     :integer          default(0), not null
#  category_id      :integer
#  bank_account_id  :integer          not null
#  created_at       :datetime
#  updated_at       :datetime
#  comment          :string
#  transaction_type :string
#  deleted_at       :datetime
#  customer_id      :integer
#  date             :datetime
#

require "./lib/time_range.rb"

class Transaction < ActiveRecord::Base
  include TimeRange
  TRANSACTION_TYPES = %w(Residue)

  acts_as_paranoid

  class AmountFlow < Struct.new(:income, :expense, :currency)
    def total
      income + expense
    end
  end

  attr_accessor :customer_name

  belongs_to :category, inverse_of: :transactions
  belongs_to :bank_account, inverse_of: :transactions, touch: true
  belongs_to :customer, inverse_of: :transactions
  has_one :organization, through: :bank_account, inverse_of: :transactions

  monetize :amount_cents, with_model_currency: :currency

  delegate :currency, to: :bank_account, allow_nil: true
  delegate :income?, :expense?, to: :category, allow_nil: true

  default_scope { order(date: :desc) }
  # scope :by_currency, ->(currency) { joins(:bank_account).where('bank_accounts.currency' => currency) }
  scope :by_currency, ->(currency) { joins("INNER JOIN bank_accounts bank_account_transactions
      ON bank_account_transactions.id = transactions.bank_account_id
      AND bank_account_transactions.deleted_at IS NULL").
      where('bank_account_transactions.currency' => currency) }
  scope :incomes,     -> { joins(:category).where('categories.type' => Category::CATEGORY_INCOME)}
  scope :expenses,    -> { joins(:category).where('categories.type' => Category::CATEGORY_EXPENSE)}

  validates :amount, presence: true, numericality: { greater_than: 0,
    less_than_or_equal_to: Dictionaries.money_max }
  validate  :amount_balance, if: :bank_account
  validates :category, presence: true, unless: :residue?
  validates :bank_account, presence: true
  validates :customer_name, length: { maximum: 255 }
  validates :transaction_type, inclusion: { in: TRANSACTION_TYPES, allow_blank: true }
  validates :date, presence: true

  before_validation :find_customer, if: Proc.new{ customer_name.present? && bank_account.present? }
  before_validation :set_date, if: Proc.new{ date.blank? }
  before_save :check_negative
  after_restore :recalculate_amount

  class << self
    def flow_ordered(def_currency)
      currencies = Currency.ordered(def_currency)

      amount_flow = all.reorder('').joins(:category).
        select("
          SUM(CASE WHEN categories.type = 'Income' THEN transactions.amount_cents ELSE 0 END) AS income,
          SUM(CASE WHEN categories.type = 'Expense' THEN transactions.amount_cents ELSE 0 END) AS expense,
          bank_accounts.currency AS currency
       ").group("bank_accounts.currency")

      if amount_flow.empty?
        amount_flow << AmountFlow.new(
          Money.empty(def_currency), Money.empty(def_currency), def_currency)
      else
        amount_flow = amount_flow.to_a
        amount_flow.sort_by! do |flow|
          currencies.index(flow["currency"])
        end

        amount_flow.map! do |flow|
          curr = flow["currency"]
          AmountFlow.new(
            Money.new(flow["income"],  curr),
            Money.new(flow["expense"], curr),
            curr)
        end
      end
    end

    def custom_dates
      [
        ["Current month: #{TimeRange.format(Time.now, 'current')}", "current-month"],
        ["Previous month: #{TimeRange.format(Time.now, 'prev_month')}", "prev-month"],
        ["Last 3 months: #{TimeRange.format(Time.now, 'last_3')}", "last-3-months"],
        ["Quarter: #{TimeRange.format(Time.now, 'quarter')}", "quarter"],
        ["This year: #{TimeRange.format(Time.now, 'year')}", "this-year"],
        ["Custom", "custom"]
      ]
    end
  end

  def find_customer_name_by_id(customer_id)
    Customer.find(customer_id).to_s
  rescue
    'Customer'
  end

  private

  def find_customer
    self.customer = Customer.find_or_initialize_by(name: customer_name, organization_id: organization.id)
  end

  def check_negative
    self.amount = Money.new(amount_cents.abs, currency) if (income? || residue?) && amount_cents < 0
    self.amount = Money.new(-amount_cents.abs, currency) if expense? && amount_cents > 0
    nil
  end

  def set_date
    self.date = Time.now
  end

  def recalculate_amount
    bank_account.recalculate_amount!
    nil
  end

  def residue?
    self.transaction_type == 'Residue'
  end

  def self.period(period)
    case period
    when 'current-month'
      where('transactions.date >= ? AND transactions.date <= ?', Time.now.beginning_of_month, Time.now)
    when 'last-3-months'
      where('transactions.date >= ? AND transactions.date <= ?', (Time.now - 3.months).beginning_of_day, Time.now)
    when 'prev-month'
      prev_month_begins = Time.now.beginning_of_month - 1.months
      where('transactions.date between ? AND ?', prev_month_begins,
        prev_month_begins.end_of_month)
    when 'this-year'
      where('transactions.date >= ? AND transactions.date <= ?', Time.now.beginning_of_year, Time.now)
    when 'quarter'
      where('transactions.date >= ? AND transactions.date <= ?', Time.now.beginning_of_quarter, Time.now)
    else
      all
    end
  end

  def self.date_from(from)
    from = DateTime.parse(from).beginning_of_day rescue nil
    if from && from.year > 0
      where("transactions.date >= ?", from)
    else
      all
    end
  end

  def self.date_to(to)
    to = DateTime.parse(to).end_of_day rescue nil
    if to && to.year > 0
      where("transactions.date <= ?", to)
    else
      all
    end
  end

  def self.amount_eq(amount)
    if (amount = amount.to_d) > 0
      where('abs(amount_cents) = ?', Money.new(amount * 100).cents)
    else
      all
    end
  end

  def self.ransackable_scopes(auth_object = nil)
    %i(amount_eq period amount_sort date_from date_to)
  end

  def amount_balance
    if expense?
      errors.add(:amount, 'Not enough money') if amount >
        bank_account.balance - Money.new(amount_cents_was, bank_account.currency).abs
    else
      errors.add(:amount, 'Balance overflow') if Dictionaries.money_max * 100 <
        (bank_account.balance + amount).cents
    end
  end
end
