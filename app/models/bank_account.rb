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
#  deleted_at      :datetime
#  visible         :boolean          default(TRUE)
#  position        :integer
#

class BankAccount < ActiveRecord::Base
  AMOUNT_MAX = 21_474_836.47

  acts_as_list
  acts_as_paranoid

  belongs_to :organization, inverse_of: :bank_accounts
  has_many :transactions, dependent: :destroy, inverse_of: :bank_account

  attr_writer :residue_cents

  monetize :balance_cents, with_model_currency: :currency
  monetize :residue_cents, with_model_currency: :currency

  scope :visible,     -> { where(visible: true) }
  scope :by_currency, -> (currency) { where('bank_accounts.currency' => currency) }
  scope :positioned,  -> { order(position: :asc) }

  validates :name,     presence: true
  validates :balance,  presence: true, numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: AMOUNT_MAX }
  validates :currency, presence: true,
    inclusion: { in: Dictionaries.currencies,
      message: "%{value} is not a valid currency" }

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
    transactions.create(amount_cents: residue_cents, transaction_type: 'Residue') if residue > 0
  end

  def to_s
    "#{name.truncate(30)} (#{Money::Currency.new(currency).symbol})"
  end

  class << self
    def grouped_by_currency(currency)
      currencies = Currency.ordered(currency)

      grouped = []
      currencies.each do |curr|
        by_currency = by_currency(curr)
        grouped << [curr, by_currency] if by_currency.present?
      end

      grouped
    end
  end
end
