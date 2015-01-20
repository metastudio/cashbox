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
  TRANSACTION_TYPES = %w(Residue Receipts Transfer)

  attr_accessor :comission

  belongs_to :category, inverse_of: :transactions
  belongs_to :bank_account, inverse_of: :transactions
  belongs_to :bank_account, inverse_of: :transactions
  belongs_to :reference, class_name: 'BankAccount', inverse_of: :transactions
  has_one :organization, through: :bank_account, inverse_of: :transactions

  monetize :amount_cents, with_model_currency: :currency

  delegate :currency, to: :bank_account, allow_nil: true
  delegate :income?, :expense?, to: :category, allow_nil: true

  default_scope { order(created_at: :desc) }

  validates :amount,   presence: true
  validates :category, presence: true, unless: :residue?
  validates :bank_account, presence: true
  validates :reference, presence: true, if: :transfer?
  validates :transaction_type, inclusion: { in: TRANSACTION_TYPES, allow_blank: true }

  before_save :check_negative
  after_save :recalculate_amount
  after_destroy :recalculate_amount

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

  def transfer?
    !comission.nil?
  end
end
