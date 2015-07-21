# == Schema Information
#
# Table name: organizations
#
#  id               :integer          not null, primary key
#  name             :string           not null
#  created_at       :datetime
#  updated_at       :datetime
#  default_currency :string           default("USD")
#

class Organization < ActiveRecord::Base
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

  def by_customers(categories_type, period)
    sum = categories_type == :expenses ? 'sum(abs(transactions.amount_cents))' : 'sum(transactions.amount_cents)'

    selection = transactions.unscope(:order).period(period).
      select("#{sum} as total, customers.name as cust_name, customers.id as customer_id, bank_accounts.currency as curr").
      joins(:customer).
      where('transactions.category_id in (?)', categories.send(categories_type).pluck(:id)).
      group('customers.id, bank_accounts.id').map do |transaction|
        {
          total:         transaction.total.to_f,
          customer_id:   transaction.customer_id,
          customer_name: transaction.cust_name,
          currency:      transaction.curr
        }
      end
    customers = {}
    data, ids = [], []
    calc_to_def_currency(customers, selection)
    calc_total_for_customer(customers, selection, data, ids)
    data.size > 1 ? { data: data, ids: ids, currency_format: currency_format } : nil
  end

  private

  def calc_to_def_currency(customers, selection)
    selection.each do |income|
      customers[income[:customer_id]] = income[:customer_name]
      if income[:currency] != default_currency
        income[:total] = Money.new(income[:total], income[:currency]).exchange_to(default_currency).cents
        income[:currency] = default_currency
      end
    end
  end

  def calc_total_for_customer(customers, selection, data, ids)
    customers.each_pair do |id, name|
      total_for_customer = 0
      selection.each do |income|
        total_for_customer += income[:total] if income[:customer_id] == id
      end
      ids  << id
      data << [ name, (total_for_customer.to_f/100).round(2) ]
    end
    data.unshift(['Customer', 'Income in default currency'])
    ids.unshift(nil)
  end

  def currency_format
    currency = Money::Currency.find(default_currency)
    format = currency.symbol_first ? { prefix: currency.symbol } : { suffix: currency.symbol }
  end
end
