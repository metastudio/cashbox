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
      where('transactions.category_id in (?) and abs(transactions.amount_cents) > 0', categories.send(categories_type).pluck(:id)).
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
      where('transactions.category_id in (?) and abs(transactions.amount_cents) > 0', categories.send(categories_type).pluck(:id)).
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

  def data_balance(scale='months', step=0)
    period = period_from_step(step.to_i, scale)
    incomes, expenses, totals = balance_data_collection(period)

    total_sum = Money.new(0, self.default_currency)
    Dictionaries.currencies.each_with_index do |currency|
      total = Money.new(self.transactions.where('DATE(date) < ? AND currency = ?', period.begin, currency).
        sum(:amount_cents), currency)
      total_sum += currency != self.default_currency ? total.exchange_to(self.default_currency) : total
    end

    data = BalanceDataCombainer.new(period, incomes, expenses, totals, total_sum.to_f).by(scale)
    data.size > 1 ? { data: data, currency_format: currency_format } : nil
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
    total = 0
    def_curr = default_currency
    invoices.unpaid.group(:currency).sum(:amount_cents).each do |currency, amount_cents|
      m = Money.new(amount_cents, currency)
      if def_curr == currency
        total += m
      else
        total += m.exchange_to(def_curr)
      end
    end
    total.format
  end

  def customers_by_months(type='income')
    category_type = type
    period = 1.year.ago.to_date .. Date.current
    months = period.map { |date| get_month(date.beginning_of_month) }.uniq
    result = {}
    customers = []
    months.each do |month|
      result[month] = {}
    end

    transacts = transactions.unscope(:order).period(period).includes(:customer)
    if category_type == 'income'
      transacts = transacts.incomes
    else
      transacts = transacts.expenses
    end
    transacts = transacts.where.not(customer: nil)

    transacts.each do |transact|
      date = get_month(transact.date)
      customer_name = "#{transact.customer.name}"
      customers << customer_name
      transact_amount = transact.amount
        .exchange_to(default_currency)
        .cents
        .abs
      transact_amount = (transact_amount/100).round(2)
      if result[date][customer_name].present?
        result[date][customer_name] += transact_amount
      else
        result[date][customer_name] = transact_amount
      end
    end
    {
      data: customers_transactions_data(customers.uniq.sort, result),
      currency_format: currency_format
    }
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
    amount = currency != default_currency \
      ? Money.new(amount, currency).exchange_to(default_currency).cents
      : Money.new(amount, default_currency).cents
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
      date = trans[:date].strftime('%b, %Y')
      trans[:total] = calc_to_def_currency(trans[:total], trans[:currency])
      hash[date] = hash[date].nil? \
        ? trans[:total] : hash[date] + trans[:total]
    end
    hash
  end

  def combine_by_months(period, incomes, expenses, totals, total_sum)
    keys = period.map(&:beginning_of_month).uniq.map{ |date| date.strftime("%b, %Y") }
    array = keys.map do |k|
      total_sum = total_sum + (totals[k].to_f || 0)/100
      [k, ((incomes[k].to_f || 0)/100).round(2), ((expenses[k].to_f || 0)/100).round(2), total_sum.round(2)]
    end
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
    format = currency.symbol_first ? { prefix: currency.symbol, decimalSymbol: '.', groupingSymbol: ',' }
                                   : { suffix: currency.symbol, decimalSymbol: '.', groupingSymbol: ',' }
  end

  def balance_data_collection(period)
    [:incomes, :expenses, :totals].map do |selection|
      query = transactions.unscope(:order)
      query = query.incomes if selection == :incomes
      query = query.expenses if selection == :expenses
      if selection == :expenses
        query = query.select("sum(abs(transactions.amount_cents)) as total, bank_accounts.currency as curr, transactions.date as date")
      else
        query = query.select("sum(transactions.amount_cents) as total, bank_accounts.currency as curr, transactions.date as date")
      end
      if selection == :incomes
        query = query.where('DATE(date) BETWEEN ? AND ? AND category_id != ?', period.begin, period.end, Category.receipt_id)
      elsif selection == :expenses
        query = query.where('DATE(date) BETWEEN ? AND ? AND category_id != ?', period.begin, period.end, Category.transfer_out_id)
      else
        query = query.where('DATE(date) BETWEEN ? AND ?', period.begin, period.end)
      end
      query = query.group('transactions.id, bank_accounts.id').map do |transaction|
          {
            date:           transaction.date,
            total:          transaction.total,
            currency:       transaction.curr
          }
      end
      calc_to_def_currency_for_data_selection(query)
    end
  end

  def customers_transactions_data(customers, data)
    result = []
    data.each do |month, mont_data|
      month_string = ["#{month}"]
      customers.each do |customer|
        if mont_data[customer].present?
          month_string << mont_data[customer]
        else
          month_string << 0
        end
      end
      month_string << ''
      result << month_string
    end
    header = customers.unshift('Customer').append({ role: 'annotation' })
    result.unshift(header)
    result
  end
end
