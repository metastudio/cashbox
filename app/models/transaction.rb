# == Schema Information
#
# Table name: transactions
#
#  id              :integer          not null, primary key
#  amount_cents    :integer          default(0), not null
#  category_id     :integer          not null
#  bank_account_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#  comment         :string(255)
#
class Transaction < ActiveRecord::Base
  CURRENCIES = %w(USD RUB)
  TRANSACTION_TYPES = %w(Residue)
  FILTER_PERIOD = [['Current month', 'current_month'], ['Last month', 'last_month'],
   ['Last 3 months', 'last_3_months'],['Quarter', 'quarter'], ['This year', 'this_year']]

  belongs_to :category, inverse_of: :transactions
  belongs_to :bank_account, inverse_of: :transactions
  has_one :organization, through: :bank_account, inverse_of: :transactions

  monetize :amount_cents, with_model_currency: :currency

  delegate :currency, to: :bank_account, allow_nil: true
  delegate :income?, :expense?, to: :category, allow_nil: true

  default_scope { order(created_at: :desc) }
  scope :rub, -> { joins(:bank_account).where('bank_accounts.currency' => "RUB") }
  scope :usd, -> { joins(:bank_account).where('bank_accounts.currency' => "USD") }

  validates :amount, presence: true
  validates :category, presence: true, unless: :residue?
  validates :bank_account, presence: true
  validates :transaction_type, inclusion: { in: TRANSACTION_TYPES, allow_blank: true }

  before_save :check_negative
  after_save :recalculate_amount
  after_destroy :recalculate_amount

  def date
    created_at.strftime("%Y-%m-%d")
  end

  private

  def check_negative
    self.amount = Money.new(amount_cents.abs, currency) if (income? || residue?) && amount_cents < 0
    self.amount = Money.new(-amount_cents.abs, currency) if expense? && amount_cents > 0
    nil
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
    when "current_month"
      where("transactions.created_at >= ?", Time.now.beginning_of_month)
    when "last_3_months"
      where("transactions.created_at >= ?", (Time.now - 3.months).beginning_of_day)
    when "last_month"
      last_month_begins = Time.now.beginning_of_month - 1.months
      where("transactions.created_at between ? AND ?", last_month_begins,
        last_month_begins.end_of_month)
    when "this_year"
      where("transactions.created_at >= ?", Time.now.beginning_of_year)
    when "quarter"
      where("transactions.created_at >= ?", Time.now.beginning_of_quarter)
    end
  end

  def self.amount_eq(amount)
    amount.delete!(',')
    where(amount_cents: Money.new(amount.to_d * 100).cents)
  end

  def self.ransackable_scopes(auth_object = nil)
    %i(amount_eq period amount_sort)
  end
end
