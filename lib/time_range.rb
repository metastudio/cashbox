module TimeRange
  def self.format(time, period)
    case period
    when 'current'
      time_to = time
      time_from = time.beginning_of_month
    when 'prev_month'
      time_to = (time - 1.month).end_of_month
      time_from = time_to.beginning_of_month
    when 'quarter'
      time_to = time
      time_from = time_to.beginning_of_quarter
    when 'year'
      time_to = time
      time_from = time_to.beginning_of_year
    when 'last_3'
      time_to = time
      time_from = (time_to - 3.months)
    end

    if time.year - time_from.year == 0
      month_day(time_from) + ' - ' + month_day(time_to)
    else
      month_day(time_from) + ', ' + time_from.year.to_s + ' - ' + month_day(time_to)
    end
  end

  private
    def self.month_day(time)
      time.strftime('%b ') + time.day.ordinalize
    end
end
