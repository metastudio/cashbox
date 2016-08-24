module DateLogic

  def get_quarter(date)
    month, year = date.split(', ')
    case month
    when 'Jan', 'Feb', 'Mar'
      "First quarter of #{year}"
    when 'Apr', 'May', 'Jun'
      "Second quarter of #{year}"
    when 'Jul', 'Aug', 'Sept'
      "Third quarter of #{year}"
    when 'Oct', 'Nov', 'Dec'
      "Fourth quarter of #{year}"
    end
  end

  def get_year(date)
    date.split(', ').last
  end

  def period_from_step(step, scale)
    case scale
    when 'months'
      (1.year.ago.to_date - step.month)..(Date.current - step.month).end_of_month
    when 'years'
      (1.year.ago.to_date - step.year)..(Date.current - step.year).end_of_month
    when 'quarters'
      (1.year.ago.to_date - (3*step).month)..(Date.current - (3*step).month).end_of_month
    end
  end

end
