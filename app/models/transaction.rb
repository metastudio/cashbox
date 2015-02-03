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

  belongs_to :category, inverse_of: :transactions
  belongs_to :bank_account, inverse_of: :transactions
  has_one :organization, through: :bank_account, inverse_of: :transactions

  monetize :amount_cents, with_model_currency: :currency

  delegate :currency, to: :bank_account, allow_nil: true
  delegate :income?, :expense?, to: :category, allow_nil: true

  default_scope { order(created_at: :desc) }

  validates :amount, presence: true
  validates :category, presence: true, unless: :residue?
  validates :bank_account, presence: true
  validates :transaction_type, inclusion: { in: TRANSACTION_TYPES, allow_blank: true }

  before_save :check_negative
  after_save :recalculate_amount
  after_destroy :recalculate_amount

  private

  def self.amount_eq(amount)
    where(amount_cents: Money.new(amount.to_d * 100).cents)
  end

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

  def self.simple_period(period)
    case period
    when "current_month"
      where("transactions.created_at >= ?", Time.now.beginning_of_month)
    when "last_3_months"
      where("transactions.created_at >= ?", Time.now - 3.months)
    when "last_month"
      last_month_begins = Time.now.beginning_of_month - 1.months
      where("transactions.created_at >= ? AND transactions.created_at <= ?", last_month_begins,
        last_month_begins.end_of_month)
    when "this_year"
      where("transactions.created_at >= ?", Time.now.beginning_of_year)
    when "quarter"
      where("transactions.created_at >= ?", Time.now.beginning_of_quarter)
    # else
      # toDo doesn't work when filter on amount and custom
      # self
    end
  end

  def self.quarter(quarter)
    first_quarter = Time.now.beginning_of_year
    case quarter
    when 'first'
      where("transactions.created_at >= ? AND transactions.created_at <= ?",
        first_quarter, first_quarter.end_of_quarter)
    when 'second'
      second_quarter = first_quarter + 3.months
      where("transactions.created_at >= ? AND transactions.created_at <= ?",
        second_quarter, second_quarter.end_of_quarter)
    when 'third'
      third_quarter = first_quarter + 6.months
      where("transactions.created_at >= ? AND transactions.created_at <= ?",
        third_quarter, third_quarter.end_of_quarter)
    when 'forth'
      forth_quarter = first_quarter + 9.months
      where("transactions.created_at >= ? AND transactions.created_at <= ?",
        forth_quarter, forth_quarter.end_of_quarter)
    end
  end

  # def self.custom_period(custom_period)
  #   from_to_arr = custom_period.split('-')
  #   from = Time.parse(from_to_arr[0])
  #   to   = Time.parse(from_to_arr[1]).try(:end_of_day)
  #   if from && to
  #     where("transactions.created_at >= ? AND transactions.created_at <= ?", from, to)
  #   end
  # end

  def self.ransackable_scopes(auth_object = nil)
    %i(amount_eq simple_period quarter)
    # %i(amount_eq simple_period quarter custom_period)
  end
end
