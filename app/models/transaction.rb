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
#  comment          :string(255)
#  transaction_type :string(255)
#  deleted_at       :datetime
#  customer_id      :integer
#  date             :datetime         not null
#  transfer_out_id  :integer
#  invoice_id       :integer
#

require "./lib/time_range.rb"

class Transaction < ActiveRecord::Base
  include MoneyRails::ActionViewExtension
  include TimeRange
  TRANSACTION_TYPES = %w(Residue)

  acts_as_paranoid

  class AmountFlow < Struct.new(:income, :expense, :currency)
    def total
      income + expense
    end
  end

  attr_accessor :customer_name, :comission

  belongs_to :category, inverse_of: :transactions
  belongs_to :bank_account, inverse_of: :transactions, touch: true
  belongs_to :customer, inverse_of: :transactions
  belongs_to :invoice
  belongs_to :transfer_out, class_name: 'Transaction', foreign_key: 'transfer_out_id', dependent: :destroy
  has_one :transfer_in, class_name: 'Transaction', foreign_key: 'transfer_out_id'
  accepts_nested_attributes_for :transfer_out
  has_one :organization, through: :bank_account, inverse_of: :transactions

  monetize :amount_cents, with_model_currency: :currency

  delegate :currency, to: :bank_account, allow_nil: true
  delegate :income?, :expense?, to: :category, allow_nil: true

  default_scope { order(date: :desc, created_at: :desc) }
  # scope :by_currency, ->(currency) { joins(:bank_account).where('bank_accounts.currency' => currency) }
  scope :by_currency, ->(currency) { joins("INNER JOIN bank_accounts bank_account_transactions
      ON bank_account_transactions.id = transactions.bank_account_id
      AND bank_account_transactions.deleted_at IS NULL").
      where('bank_account_transactions.currency' => currency) }
  scope :incomes,     -> { joins(:category).where('categories.type' => Category::CATEGORY_INCOME)}
  scope :expenses,    -> { joins(:category).where('categories.type' => Category::CATEGORY_EXPENSE)}
  scope :without_out, -> (bank_accounts) { where('category_id IS NULL OR category_id != ?
      OR bank_account_id IN (?)', Category.transfer_out_id, bank_accounts) }

  validates :amount, presence: true, numericality: {
    less_than_or_equal_to: Dictionaries.money_max }
  validate  :amount_balance, if: :bank_account
  validates :category, presence: true, unless: :residue?
  validates :bank_account, presence: true
  validates :customer_name, :comment, length: { maximum: 255 }
  validates :transaction_type, inclusion: { in: TRANSACTION_TYPES, allow_blank: true }
  validates :date, presence: true
  validates :comission, numericality: { greater_than_or_equal_to: 0 },
    length: { maximum: 10 }, allow_blank: true
  validate :check_comission, if: :comission
  validate :check_bank_accounts, on: :update, if: Proc.new{ transfer? }

  before_validation :find_customer, if: Proc.new{ customer_name.present? && bank_account.present? }
  before_validation :set_date, if: Proc.new{ date.blank? }
  before_save :check_negative
  before_save :sync_date, if: Proc.new{ transfer? }
  before_save :calculate_amount, if: :comission
  after_restore :recalculate_amount
  after_save :update_invoice_paid_at, if: :invoice

  class << self
    def flow_ordered(def_currency)
      currencies = Currency.ordered(def_currency)

      amount_flow = all.reorder('').joins(:category).
        select("
          SUM(CASE WHEN categories.type = 'Income' THEN transactions.amount_cents ELSE 0 END) AS income,
          SUM(CASE WHEN categories.type = 'Expense' THEN transactions.amount_cents ELSE 0 END) AS expense,
          bank_accounts.currency AS currency
        ").
        where('category_id != ? AND category_id != ?', Category.receipt_id, Category.transfer_out_id).
        group("bank_accounts.currency")

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
        ["Current month: #{TimeRange.format(Time.current, 'current')}", "current-month"],
        ["Previous month: #{TimeRange.format(Time.current, 'prev_month')}", "prev-month"],
        ["Last 3 months: #{TimeRange.format(Time.current, 'last_3')}", "last-3-months"],
        ["Quarter: #{TimeRange.format(Time.current, 'quarter')}", "quarter"],
        ["This year: #{TimeRange.format(Time.current, 'year')}", "this-year"],
        ["Custom", "custom"]
      ]
    end
  end

  def transfer?
    category_id == Category.receipt_id
  end

  def transfer_out?
    category_id == Category.transfer_out_id
  end

  private

  def find_customer
    self.customer = Customer.find_or_initialize_by(name: customer_name, organization_id: organization.id)
  end

  def sync_date
    transfer_out.update(date: date)
  end

  def check_bank_accounts
    if bank_account_id == transfer_out.bank_account_id
      errors.add(:bank_account_id, "Can't transfer to same account")
    end
  end

  def check_negative
    self.amount = Money.new(amount_cents.abs, currency) if (income? || residue?) && amount_cents < 0
    self.amount = Money.new(-amount_cents.abs, currency) if expense? && amount_cents > 0
    nil
  end

  def set_date
    self.date = Time.current
  end

  def check_comission
    errors.add(:comission, "Can't be more than amount") if self.comission.to_d >= self.amount.to_d
  end

  def calculate_amount
    self.amount = Money.new(amount_cents - comission.to_d * 100, currency)
    add_comission_to_comment
  end

  def recalculate_amount
    bank_account.recalculate_amount!
    nil
  end

  def add_comission_to_comment
    self.comment += "\nComission: " +
      humanized_money_with_symbol(Money.new(comission.to_d * 100, bank_account.currency),
      symbol_after_without_space: true)
  end

  def residue?
    self.transaction_type == 'Residue'
  end

  def update_invoice_paid_at
    self.organization.invoices.where(id: self.invoice_id).first.try(:update, {paid_at: self.date})
  end

  def self.period(period)
    case period
    when 'current-month'
      where('DATE(transactions.date) between ? AND ?', Date.current.beginning_of_month, Date.current.end_of_month)
    when 'last-3-months'
      where('DATE(transactions.date) between ? AND ?', (Date.current - 3.months).beginning_of_day, Date.current.end_of_month)
    when 'prev-month'
      prev_month_begins = Date.current.beginning_of_month - 1.months
      where('DATE(transactions.date) between ? AND ?', prev_month_begins,
        prev_month_begins.end_of_month)
    when 'this-year'
      where('DATE(transactions.date) between ? AND ?', Date.current.beginning_of_year, Date.current.end_of_year)
    when 'quarter'
      where('DATE(transactions.date) between ? AND ?', Date.current.beginning_of_quarter, Date.current.end_of_quarter)
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
    errors.add(:amount, 'Balance overflow') if Dictionaries.money_max * 100 <
      (bank_account.balance + amount).cents
  end
end
