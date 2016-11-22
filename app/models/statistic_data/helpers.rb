module StatisticData
  module Helpers
    def get_customers_selection_by_invoice_items(period)
      nil_date_items = @organization.invoices.period(period).
        select('sum(invoice_items.amount_cents) as total, invoice_items.customer_id, invoice_items.currency').
        joins(:invoice_items).
        where('invoice_items.date IS NULL').
        group('invoice_items.customer_id, invoice_items.currency')

      items = @organization.invoice_items.period(period).
        select('sum(invoice_items.amount_cents) as total, invoice_items.customer_id, invoice_items.currency').
        where('invoice_items.date IS NOT NULL').
        group('invoice_items.customer_id, invoice_items.currency')

      customers_selection_format_output(nil_date_items) + customers_selection_format_output(items)
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

    def find_customer_name_by_id(customer_id)
      self.customers.find(customer_id).to_s
    rescue
      ''
    end

    def get_customers_selection_by_transactions(type, customer_ids, period)
      @organization.transactions.unscope(:order).period(period).
        select("sum(transactions.amount_cents) as total, customers.name as cust_name, customers.id as customer_id, bank_accounts.currency as curr").
        joins(:customer).
        where('transactions.category_id in (?) AND customers.id in (?)',
          @organzation.categories.send(type).pluck(:id), customer_ids).
        group('customers.id, bank_accounts.id').map do |transaction|
          {
            total:          transaction.total.to_f,
            selection_id:   transaction.customer_id,
            selection_name: transaction.cust_name,
            currency:       transaction.curr
          }
        end
    end

    def default_currency
      @organization.default_currency
    end

    def calc_to_def_currency(amount, currency)
      amount = currency != default_currency \
        ? Money.new(amount, currency).exchange_to(default_currency).cents
        : Money.new(amount, default_currency).cents
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

    def currency_format
      currency = Money::Currency.find(default_currency)
      format = currency.symbol_first ? { prefix: currency.symbol, decimalSymbol: '.', groupingSymbol: ',' }
                                     : { suffix: currency.symbol, decimalSymbol: '.', groupingSymbol: ',' }
    end

    def calc_to_def_currency_for_selection(selection)
      hash = {}
      selection.each do |trans|
        hash[trans[:selection_id]] = trans[:selection_name] if trans[:selection_id]
        trans[:total] = calc_to_def_currency(trans[:total], trans[:currency])
      end
      hash
    end

    def customers_selection_format_output(selection)
      selection.map do |item|
        {
          total:          item.total.to_f,
          selection_id:   item.customer_id,
          selection_name: find_customer_name_by_id(item.customer_id),
          currency:       item.currency
        }
      end
    end
  end
end
