# == Schema Information
#
# Table name: bank_accounts
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  description     :string(255)
#  balance_cents   :integer          default(0), not null
#  currency        :string(255)      default("USD"), not null
#  organization_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#

class BankAccount < ActiveRecord::Base
  CURRENCY_USD = 'USD'
  CURRENCY_RUB = 'RUB'
  CURRENCIES = [CURRENCY_USD, CURRENCY_RUB]

  belongs_to :organization, inverse_of: :bank_accounts
  has_many :transactions, dependent: :destroy, inverse_of: :bank_account

  attr_writer :residue_cents

  monetize :balance_cents, with_model_currency: :currency
  monetize :residue_cents, with_model_currency: :currency

  validates :name,     presence: true
  validates :balance,  presence: true
  validates :currency, presence: true, inclusion: { in: CURRENCIES, message: "%{value} is not a valid currency" }

  after_create :set_initial_residue

  def residue_cents
    @residue_cents ||= 0
  end

  def self.total_balance(currency)
    Money.new(where(currency: currency).sum(:balance_cents), currency)
  end

  def recalculate_amount!
    update_attributes(balance: Money.new(transactions.sum(:amount_cents), currency))
  end

  def set_initial_residue
    transactions.create(amount: residue, transaction_type: 'Residue') if residue > 0
  end

  def to_s
    "#{name} (#{Money::Currency.new(currency).symbol})"
  end
end
