# frozen_string_literal: true

module Period
  # PERIODS = [
  #   'current-month',
  #   'last-month',
  #   'last-3-months',
  #   'current-quarter',
  #   'last-quarter',
  #   'current-year',
  #   'last-year',
  # ].freeze

  extend ActiveSupport::Concern

  class_methods do # rubocop:disable Metrics/BlockLength
    def period(period)
      range = date_range(period)
      return all unless range

      table = table_name
      db_date_field = table == 'invoices' ? "#{table}.ends_at" : "#{table}.date"

      where("DATE(#{db_date_field}) between ? AND ?", range.first, range.last)
    end

    def format_period(period)
      current_date = Date.current
      range = date_range(period)
      return nil unless range

      if current_date.year == range.first.year && current_date.year == range.last.year
        month_day(range.first) + ' - ' + month_day(range.last)
      else
        month_year_day(range.first) + ' - ' + month_year_day(range.last)
      end
    end

    private

    def date_range(period) # rubocop:disable Metrics/CyclomaticComplexity
      date = Date.current
      case period
      when 'current-month'
        date.beginning_of_month..date.end_of_month
      when 'last-month'
        date -= 1.month
        date.beginning_of_month..date.end_of_month
      when 'last-3-months'
        (date - 3.months)..date
      when 'current-quarter'
        date.beginning_of_quarter..date.end_of_quarter
      when 'last-quarter'
        date -= 3.months
        date.beginning_of_quarter..date.end_of_quarter
      when 'current-year'
        date.beginning_of_year..date.end_of_year
      when 'last-year'
        date -= 1.year
        date.beginning_of_year..date.end_of_year
      end
    end

    def month_day(date)
      date.strftime("%b #{date.day.ordinalize}")
    end

    def month_year_day(date)
      date.strftime("%b #{date.day.ordinalize}, %Y")
    end
  end
end
