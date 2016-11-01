module StatisticData
  class ColumnsChart

    include DateLogic
    include StatisticData::Helpers

    def initialize(organization)
      @organization = organization
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

    def data_balance(scale='months', step=0)
      period = period_from_step(step.to_i, scale)
      incomes, expenses, totals = balance_data_collection(period)
      balance_period_blank?(period_from_step(step.to_i + 1, scale))

      total_sum = Money.new(0, default_currency)
      Dictionaries.currencies.each_with_index do |currency|
        total = Money.new(@organization.transactions.where('DATE(date) < ? AND currency = ?', period.begin, currency).
          sum(:amount_cents), currency)
        total_sum += currency != default_currency ? total.exchange_to(default_currency) : total
      end

      data = BalanceDataCombainer.new(period, incomes, expenses, totals, total_sum.to_f).by(scale)
      if data.size > 1
        {
          data: data,
          currency_format: currency_format,
          next_step_blank: balance_period_blank?(period_from_step(step.to_i + 1, scale))
        }
      else
        nil
      end
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

      transacts = @organization.transactions.unscope(:order).period(period).includes(:customer)
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

    def balance_data_collection(period)
      [:incomes, :expenses, :totals].map do |selection|
        query = @organization.transactions.unscope(:order)
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

    def balance_period_blank?(period)
      incomes_count = @organization.transactions
        .incomes
        .where('DATE(date) BETWEEN ? AND ? AND category_id != ?',
          period.begin, period.end, Category.receipt_id)
        .count
      expenses_count = @organization.transactions
        .expenses
        .where('DATE(date) BETWEEN ? AND ? AND category_id != ?',
          period.begin, period.end, Category.transfer_out_id)
        .count
      (incomes_count + expenses_count) == 0
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
end
