module TimeRange
  def self.period(time, period_name)
    case period_name
    when 'current-month'
      time_to = time
      time_from = time.beginning_of_month
    when 'previous-month'
      time_to = (time - 1.month).end_of_month
      time_from = time_to.beginning_of_month
    when 'current-quarter'
      time_to = time
      time_from = time_to.beginning_of_quarter
    when 'this-year'
      time_to = time
      time_from = time_to.beginning_of_year
    when 'last-3-months'
      time_to = time
      time_from = (time_to - 3.months)
    else
      return nil
    end
    [time_from, time_to]
  end

  def self.format(time, period_name)
    from_to   = self.period(time, period_name)
    time_from = from_to[0]
    time_to   = from_to[1]

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
