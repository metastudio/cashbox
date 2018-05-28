module Period
  extend ActiveSupport::Concern

  class_methods do
    def period(period)
      table = table_name
      db_date_field = ''
      if table == 'invoices'
        db_date_field = "#{table}.ends_at"
      else
        db_date_field = "#{table}.date"
      end
      case period
      when 'current-month'
        where("DATE(#{db_date_field}) between ? AND ?", Date.current.beginning_of_month, Date.current.end_of_month)
      when 'last-3-months'
        where("DATE(#{db_date_field}) between ? AND ?", (Date.current - 3.months).beginning_of_day, Date.current.end_of_month)
      when 'prev-month'
        prev_month_begins = Date.current.beginning_of_month - 1.months
        where("DATE(#{db_date_field}) between ? AND ?", prev_month_begins,
          prev_month_begins.end_of_month)
      when 'this-year'
        where("DATE(#{db_date_field}) between ? AND ?", Date.current.beginning_of_year, Date.current.end_of_year)
      when 'quarter'
        where("DATE(#{db_date_field}) between ? AND ?", Date.current.beginning_of_quarter, Date.current.end_of_quarter)
      else
        all
      end
    end
  end
end
