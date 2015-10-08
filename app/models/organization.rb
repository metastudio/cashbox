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
  has_many :invoices, dependent: :destroy, inverse_of: :organization
  has_many :invoice_items, through: :invoices

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

  def totals_by_customers(period)
    invoice_selection = get_customers_selection_by_invoice_items(period)
    customer_ids = invoice_selection.map{ |h| h[:selection_id] }.compact.uniq
    customers = calc_to_def_currency_for_selection(invoice_selection)
    invoice_incomes = calc_total_for_selection(customers, invoice_selection)

    selection = get_customers_selection_by_transactions(:incomes, customer_ids, period)
    customers = calc_to_def_currency_for_selection(selection)
    incomes = calc_total_for_selection(customers, selection)

    total_incomes = invoice_incomes.merge(incomes){ |k, v1, v2| [find_customer_name_by_id(k) + ' ' +
      Money.new((v1[1] + v2[1])*100, default_currency).format(symbol_after_without_space: true),
        v1[1] + v2[1]] }

    selection = get_customers_selection_by_transactions(:expenses, customer_ids, period)
    customers = calc_to_def_currency_for_selection(selection)
    expenses = calc_total_for_selection(customers, selection)

    data = total_incomes.merge(expenses){ |k, v1, v2| [find_customer_name_by_id(k) + ' ' +
      Money.new((v1[1] + v2[1])*100, default_currency).format(symbol_after_without_space: true),
        (v1[1] + v2[1]).to_f > 0 ? v1[1] + v2[1] : 0] }

    data = Hash[data.sort_by{|k, v| v[1]}.reverse]
    data = {nil => ["Hash", "In default currency"]}.merge(data)

    data.keys.size > 1 ? { data: data.values, ids: data.keys, currency_format: currency_format } : nil
  end

  def balances_by_customers(period)
    invoice_selection = get_customers_selection_by_invoice_items(period)
    customer_ids = invoice_selection.map{ |h| h[:selection_id] }.compact.uniq
    customers = calc_to_def_currency_for_selection(invoice_selection)
    invoice_incomes = calc_total_for_selection(customers, invoice_selection)

    selection = get_customers_selection_by_transactions(:incomes, customer_ids, period)
    customers = calc_to_def_currency_for_selection(selection)
    incomes = calc_total_for_selection(customers, selection)

    total_incomes = invoice_incomes.merge(incomes){ |k, v1, v2| [find_customer_name_by_id(k) + ' ' +
      (v1[1] + v2[1]).to_s, v1[1] + v2[1]] }

    selection = get_customers_selection_by_transactions(:expenses, customer_ids, period)
    customers = calc_to_def_currency_for_selection(selection)
    expenses = calc_total_for_selection(customers, selection)

    data = combine_by_customers(customer_ids, total_incomes, expenses)
    data.size > 1 ? { data: data, currency_format: currency_format } : nil
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
          selection_id:   transaction.customer_id,
          selection_name: transaction.cust_name,
          currency:      transaction.curr
        }
      end
    other_selection = transactions.unscope(:order).period(period).
      select("#{sum} as total, bank_accounts.currency as curr").
      where('transactions.category_id in (?) AND customer_id is NULL', categories.send(categories_type).pluck(:id)).
      group('bank_accounts.id').map do |transaction|
        {
          total:         transaction.total.to_f,
          currency:      transaction.curr
        }
      end

    customers = calc_to_def_currency_for_selection(selection)
    data = calc_total_for_selection(customers, selection)
    other_sum = calc_total(other_selection)

    data.merge!(0 => ['Other ' + Money.new(other_sum, default_currency).format(symbol_after_without_space: true), other_sum.to_f/100.round(2)]) if other_sum > 0
    data = Hash[data.sort_by{|k, v| v[1]}.reverse]
    data = {nil => ["Hash", "In default currency"]}.merge(data)
    data.keys.size > 1 ? { data: data.values, ids: data.keys, currency_format: currency_format } : nil
  end

  def by_categories(categories_type, period)
    sum = categories_type == :expenses ? 'sum(abs(transactions.amount_cents))' : 'sum(transactions.amount_cents)'

    selection = transactions.unscope(:order).period(period).
      select("#{sum} as total, categories.name as cat_name, categories.id as cat_id, bank_accounts.currency as curr").
      joins(:category).
      where('transactions.category_id in (?)', categories.send(categories_type).pluck(:id)).
      group('categories.id, bank_accounts.id').map do |transaction|
        {
          total:         transaction.total.to_f,
          selection_id:   transaction.cat_id,
          selection_name: transaction.cat_name,
          currency:      transaction.curr
        }
      end
    categories = calc_to_def_currency_for_selection(selection)
    data = calc_total_for_selection(categories, selection)

    data = Hash[data.sort_by{|k, v| v[1]}.reverse]
    data = {nil => ["Hash", "In default currency"]}.merge(data)

    data.keys.size > 1 ? { data: data.values, ids: data.keys, currency_format: currency_format } : nil
  end

  def data_balance
    period = 1.year.ago.to_datetime..Time.current.to_datetime
    income_selection = transactions.unscope(:order).incomes.
      select("sum(transactions.amount_cents) as total, bank_accounts.currency as curr, transactions.date as date").
      where('DATE(date) BETWEEN ? AND ? AND category_id != ?', period.begin, period.end, Category.receipt_id).
      group('transactions.id, bank_accounts.id').map do |transaction|
        {
          date:           transaction.date,
          total:          transaction.total.to_f,
          currency:       transaction.curr
        }
      end
    expense_selection = transactions.unscope(:order).expenses.
      select("sum(abs(transactions.amount_cents)) as total, bank_accounts.currency as curr, transactions.date as date").
      where('DATE(date) BETWEEN ? AND ? AND category_id != ?', period.begin, period.end, Category.transfer_out_id).
      group('transactions.id, bank_accounts.id').map do |transaction|
        {
          date:           transaction.date,
          total:          transaction.total.to_f,
          currency:       transaction.curr
        }
      end
    incomes = calc_to_def_currency_for_data_selection(income_selection)
    expenses = calc_to_def_currency_for_data_selection(expense_selection)
    data = combine_by_months(period, incomes, expenses)
    data.size > 1 ? { data: data, currency_format: currency_format } : nil
  end

  def find_customer_name_by_id(customer_id)
    self.customers.find(customer_id).to_s
  rescue
    ''
  end

  def to_s
    name.truncate(30)
  end

  private

  def get_customers_selection_by_transactions(type, customer_ids, period)
    transactions.unscope(:order).period(period).
      select("sum(transactions.amount_cents) as total, customers.name as cust_name, customers.id as customer_id, bank_accounts.currency as curr").
      joins(:customer).
      where('transactions.category_id in (?) AND customers.id in (?)',
        categories.send(type).pluck(:id), customer_ids).
      group('customers.id, bank_accounts.id').map do |transaction|
        {
          total:          transaction.total.to_f,
          selection_id:   transaction.customer_id,
          selection_name: transaction.cust_name,
          currency:       transaction.curr
        }
      end
  end

  def get_customers_selection_by_invoice_items(period)
    nil_date_items = invoices.period(period).
      select('sum(invoice_items.amount_cents) as total, invoice_items.customer_id, invoice_items.currency').
      joins(:invoice_items).
      where('invoice_items.date IS NULL').
      group('invoice_items.customer_id, invoice_items.currency').map do |item|
      {
        total:          item.total.to_f,
        selection_id:   item.customer_id,
        selection_name: find_customer_name_by_id(item.customer_id),
        currency:       item.currency
      }
    end

    items = invoice_items.period(period).
      select('sum(invoice_items.amount_cents) as total, invoice_items.customer_id, invoice_items.currency').
      where('invoice_items.date IS NOT NULL').
      group('invoice_items.customer_id, invoice_items.currency').map do |item|
      {
        total:          item.total.to_f,
        selection_id:   item.customer_id,
        selection_name: find_customer_name_by_id(item.customer_id),
        currency:       item.currency
      }
    end
    selection = nil_date_items + items
  end

  def calc_to_def_currency(amount, currency)
    amount = Money.new(amount, currency).exchange_to(default_currency).cents if currency != default_currency
    amount
  end

  def calc_total(selection)
    sum = 0
    selection.each do |trans|
      sum += calc_to_def_currency(trans[:total], trans[:currency])
    end
    sum
  end

  def calc_to_def_currency_for_data_selection(selection)
    hash = {}
    selection.each do |trans|
      trans[:total] = calc_to_def_currency(trans[:total], trans[:currency])
      hash[trans[:date].strftime('%b, %Y')] = hash[trans[:date].strftime('%b, %Y')].nil? ? trans[:total] : hash[trans[:date].strftime('%b, %Y')] + trans[:total]
    end
    hash
  end

  def combine_by_months(period, incomes, expenses)
    keys = period.map(&:beginning_of_month).uniq.map{ |date| date.strftime("%b, %Y") }
    array = keys.map{ |k| [k, (incomes[k].to_f/100).round(2) || 0, (expenses[k].to_f/100).round(2) || 0,
      ((incomes[k].to_f - expenses[k].to_f)/100).round(2)] }
    data = array.unshift(['Month', 'Incomes', 'Expenses', 'Total balance'])
  end

  def combine_by_customers(customer_ids, incomes, expenses)
    incomes.delete(nil)
    expenses.delete(nil)
    array = customer_ids.map{ |k| [find_customer_name_by_id(k), incomes[k] ? incomes[k].last : 0,
      expenses[k] ? expenses[k].last.abs : 0] }
    data = array.unshift(['Customer', 'Incomes', 'Expenses'])
  end

  def calc_to_def_currency_for_selection(selection)
    hash = {}
    selection.each do |trans|
      hash[trans[:selection_id]] = trans[:selection_name] if trans[:selection_id]
      trans[:total] = calc_to_def_currency(trans[:total], trans[:currency])
    end
    hash
  end

  def calc_total_for_selection(selection_hash, selection)
    hash = {}
    selection_hash.each_pair do |id, name|
      total = 0
      selection.each do |trans|
        total += trans[:total] if trans[:selection_id] == id
      end
      hash[id] = [name.truncate(20) + ' ' + Money.new(total,
                    default_currency).format(symbol_after_without_space: true),
                  (total.to_f/100).round(2)]
    end
    hash
  end

  def currency_format
    currency = Money::Currency.find(default_currency)
    format = currency.symbol_first ? { prefix: currency.symbol } : { suffix: currency.symbol }
  end
end
