# == Schema Information
#
# Table name: organizations
#
#  id               :integer          not null, primary key
#  name             :string(255)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  default_currency :string(255)      default("USD")
#

class Organization < ApplicationRecord

  include DateLogic

  has_many :owners,
    -> { where members: { role: "owner" } }, through: :members, source: :user
  has_many :members, inverse_of: :organization, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :users, through: :members
  has_many :bank_accounts, dependent: :destroy, inverse_of: :organization
  has_many :transactions, through: :bank_accounts, inverse_of: :organization
  has_many :invitations, through: :members, source: :created_invitations,
    inverse_of: :organization, dependent: :destroy
  has_many :customers, dependent: :destroy, inverse_of: :organization
  has_many :invoices, dependent: :destroy, inverse_of: :organization
  has_many :invoice_items, through: :invoices

  accepts_nested_attributes_for :bank_accounts, reject_if: :all_blank, allow_destroy: true
  accepts_nested_attributes_for :categories, reject_if: :all_blank, allow_destroy: true

  validates :name, presence: true

  def ordered_curr
    currencies = bank_accounts.pluck(:currency).uniq.sort
    currencies.delete(default_currency)
    currencies.unshift(default_currency)
  end

  def exchange_rates
    org_curr = ordered_curr
    org_rates = []
    org_curr.each_with_index do |curr, i|
      org_curr[(i + 1)..-1].each do |to_curr|
        org_rates << curr + '_TO_' + to_curr
        org_rates << to_curr + '_TO_' + curr
      end
    end

    bank_rates = Money.default_bank.rates.deep_dup.keep_if do |curr_to_curr, value|
      org_rates.any? do |org_rate|
        curr_to_curr == org_rate
      end
    end
  end

  def total_balances
    bank = Money.default_bank
    balances = []
    total_amount = Money.new(0, self.default_currency)
    Dictionaries.currencies.each do |currency|
      total = self.bank_accounts.total_balance(currency)
      total_amount = total_amount + total.exchange_to(self.default_currency)
      if currency != self.default_currency
        balances << { total: total, ex_total: total.exchange_to(self.default_currency), currency: currency,
          rate: bank.get_rate(total.currency, self.default_currency).round(4), updated_at: bank.rates_updated_at }
      else
        balances << { total: total, ex_total: nil, currency: currency, rate: nil, updated_at: nil }
      end
    end
    balances.unshift({ total_amount: total_amount, default_currency: self.default_currency })
  end

  def find_customer_name_by_id(customer_id)
    self.customers.find(customer_id).to_s
  rescue
    ''
  end

  def invoice_debtors
    debtors_ids = self.invoices.unpaid.pluck(:customer_id).uniq
    Customer.where(id: debtors_ids)
  end

  def to_s
    name.truncate(30)
  end

  def total_invoice_debt
    Debts::OrganizationDebt.new(self).total.format
  end
end
