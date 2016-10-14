module Period
  extend ActiveSupport::Concern

  class_methods do
    def period(period)
      case period
      when 'current-month'
        where('DATE(transactions.date) between ? AND ?', Date.current.beginning_of_month, Date.current.end_of_month)
      when 'last-3-months'
        where('DATE(transactions.date) between ? AND ?', (Date.current - 3.months).beginning_of_day, Date.current.end_of_month)
      when 'prev-month'
        prev_month_begins = Date.current.beginning_of_month - 1.months
        where('DATE(transactions.date) between ? AND ?', prev_month_begins,
          prev_month_begins.end_of_month)
      when 'this-year'
        where('DATE(transactions.date) between ? AND ?', Date.current.beginning_of_year, Date.current.end_of_year)
      when 'quarter'
        where('DATE(transactions.date) between ? AND ?', Date.current.beginning_of_quarter, Date.current.end_of_quarter)
      else
        all
      end
    end
  end
end
