module Period
  extend ActiveSupport::Concern

  class_methods do
    def period(period)
      table = table_name
      db_date_field = table == 'invoices' ? "#{table}.ends_at" : "#{table}.date"
      return all unless periods.include?(period)
      begining, ending = period_ends(period)
      where("DATE(#{db_date_field}) between ? AND ?", begining, ending)
    end

    private def periods
      ['current-month', 'last-3-months', 'prev-month', 'this-year', 'quarter']
    end

    private def period_ends(period)
      case period
      when 'current-month'
        [Date.current.beginning_of_month, Date.current.end_of_month]
      when 'last-3-months'
        [(Date.current - 3.months).beginning_of_day, Date.current.end_of_month]
      when 'prev-month'
        prev_month_begins = Date.current.beginning_of_month - 1.month
        [prev_month_begins, prev_month_begins.end_of_month]
      when 'this-year'
        [Date.current.beginning_of_year, Date.current.end_of_year]
      when 'quarter'
        [Date.current.beginning_of_quarter, Date.current.end_of_quarter]
      end
    end
  end
end
