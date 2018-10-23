# frozen_string_literal: true

class BalanceDataCombainer
  include DateLogic

  def initialize(period, incomes, expenses, totals, total_sum)
    @period = period
    @incomes = incomes
    @expenses = expenses
    @totals = totals
    @total_sum = total_sum
  end

  def by(scale)
    case scale
    when 'months'
      by_months
    when 'years'
      by_years
    when 'quarters'
      by_quarters
    end
  end

  def by_months
    keys = @period.map(&:beginning_of_month)
      .uniq.map{ |date| date.strftime('%b, %Y') }

    array = tabletype_data(keys)
    array.unshift(['Month', 'Incomes', 'Expenses', 'Total balance'])
  end

  def by_years
    keys = @period.map(&:beginning_of_year)
      .uniq.map{ |date| date.strftime('%Y') }

    @incomes, @expenses, @totals = [@incomes, @expenses, @totals].map do |s|
      combine_by_years(s)
    end

    array = tabletype_data(keys)
    array.unshift(['Year', 'Incomes', 'Expenses', 'Total balance'])
  end

  def by_quarters
    keys = @period.map(&:beginning_of_quarter)
      .uniq.map{ |date| get_quarter(date.strftime('%b, %Y')) }

    @incomes, @expenses, @totals = [@incomes, @expenses, @totals].map do |s|
      combine_by_quarters(s)
    end

    array = tabletype_data(keys)
    array.unshift(['Quarter', 'Incomes', 'Expenses', 'Total balance'])
  end

  private

  def combine_by_years(selection)
    hash = {}
    selection.each do |date, sum|
      year = get_year(date)
      hash[year] = hash[year].nil? ? sum : hash[year] + sum
    end
    hash
  end

  def combine_by_quarters(selection)
    hash = {}
    selection.each do |date, sum|
      quarter = get_quarter(date)
      hash[quarter] = hash[quarter].nil? ? sum : hash[quarter] + sum
    end
    hash
  end

  def tabletype_data(keys)
    keys.map do |k|
      @total_sum += (@totals[k].to_f || 0) / 100
      [
        k,
        ((@incomes[k].to_f || 0) / 100).round(2),
        ((@expenses[k].to_f || 0) / 100).round(2),
        @total_sum.round(2),
      ]
    end
  end
end
