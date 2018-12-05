# frozen_string_literal: true

module StatisticData
  class RoundChart
    include StatisticData::Helpers

    def initialize(organization)
      @organization = organization
    end

    def totals_by_customers(period)
      invoice_selection = get_customers_selection_by_invoice_items(period)
      customer_ids = invoice_selection.map{ |h| h[:selection_id] }.compact.uniq
      customers = calc_to_def_currency_for_selection(invoice_selection)
      invoice_incomes = calc_total_for_selection(customers, invoice_selection)

      selection = get_customers_selection_by_transactions(:incomes, customer_ids, period)
      customers = calc_to_def_currency_for_selection(selection)
      incomes = calc_total_for_selection(customers, selection)

      total_incomes = invoice_incomes.merge(incomes) do |k, v1, v2|
        [
          find_customer_name_by_id(k) + ' ' + Money.new((v1[1] + v2[1]) * 100, default_currency).format(symbol_after_without_space: true),
          (v1[1] + v2[1]).round(2),
        ]
      end

      selection = get_customers_selection_by_transactions(:expenses, customer_ids, period)
      customers = calc_to_def_currency_for_selection(selection)
      expenses = calc_total_for_selection(customers, selection)

      data = total_incomes.merge(expenses) do |k, v1, v2|
        [
          find_customer_name_by_id(k) + ' ' + Money.new((v1[1] + v2[1]) * 100, default_currency).format(symbol_after_without_space: true),
          (v1[1] + v2[1]).to_f.positive? ? v1[1] + v2[1] : 0,
        ]
      end

      format_output(data)
    end

    def by_customers(categories_type, period)
      sum = categories_type == :expenses ? 'sum(abs(transactions.amount_cents))' : 'sum(transactions.amount_cents)'

      selection = @organization.transactions.unscope(:order).period(period)
        .select("#{sum} as total, customers.name as cust_name, customers.id as customer_id, bank_accounts.currency as curr")
        .joins(:customer)
        .where('transactions.category_id in (?) and abs(transactions.amount_cents) > 0', @organization.categories.send(categories_type).pluck(:id))
        .group('customers.id, bank_accounts.id').map do |transaction|
          {
            total:          transaction.total.to_f,
            selection_id:   transaction.customer_id,
            selection_name: transaction.cust_name,
            currency:       transaction.curr,
          }
        end
      other_selection = @organization.transactions.unscope(:order).period(period)
        .select("#{sum} as total, bank_accounts.currency as curr")
        .where('transactions.category_id in (?) AND customer_id is NULL', @organization.categories.send(categories_type).pluck(:id))
        .group('bank_accounts.id').map do |transaction|
          {
            total:    transaction.total.to_f,
            currency: transaction.curr,
          }
        end

      customers = calc_to_def_currency_for_selection(selection)
      data      = calc_total_for_selection(customers, selection)
      other_sum = calc_total(other_selection)

      if other_sum.positive?
        data[0] = [
          'Other ' + Money.new(other_sum, default_currency).format(symbol_after_without_space: true),
          other_sum.to_f / 100.round(2),
        ]
      end
      format_output(data)
    end

    def by_categories(categories_type, period)
      sum = categories_type == :expenses ? 'sum(abs(transactions.amount_cents))' : 'sum(transactions.amount_cents)'

      selection = @organization.transactions.unscope(:order).period(period)
        .select("#{sum} as total, categories.name as cat_name, categories.id as cat_id, bank_accounts.currency as curr")
        .joins(:category)
        .where('transactions.category_id in (?) and abs(transactions.amount_cents) > 0', @organization.categories.send(categories_type).pluck(:id))
        .group('categories.id, bank_accounts.id').map do |transaction|
          {
            total:          transaction.total.to_f,
            selection_id:   transaction.cat_id,
            selection_name: transaction.cat_name,
            currency:       transaction.curr,
          }
        end
      categories = calc_to_def_currency_for_selection(selection)
      data = calc_total_for_selection(categories, selection)
      format_output(data)
    end

    private

    def calc_total(selection)
      sum = 0
      selection.each do |trans|
        sum += calc_to_def_currency(trans[:total], trans[:currency])
      end
      sum
    end

    def format_output(data)
      data = Hash[data.sort_by{ |_k, v| v[1] }.reverse]
      data = { nil => ['Hash', 'In default currency'] }.merge(data)
      return nil if data.keys.size <= 1

      { data: data.values, ids: data.keys, currency_format: currency_format }
    end
  end
end
