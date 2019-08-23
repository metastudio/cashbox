# frozen_string_literal: true

module DateLogic
  MONTHS_PERIOD   = 1.year
  YEARS_PERIOD    = 5.years
  QUARTERS_PERIOD = 3.years

  def get_quarter(date)
    month, year = date.split(', ')
    case month
    when 'Jan', 'Feb', 'Mar'
      "First quarter of #{year}"
    when 'Apr', 'May', 'Jun'
      "Second quarter of #{year}"
    when 'Jul', 'Aug', 'Sep'
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
      (MONTHS_PERIOD.ago.to_date - step.month).beginning_of_month..(Date.current - step.month).end_of_month
    when 'years'
      (YEARS_PERIOD.ago.to_date - step.year).beginning_of_year..(Date.current - step.year).end_of_month
    when 'quarters'
      (QUARTERS_PERIOD.ago.to_date - (3 * step).month).beginning_of_month..(Date.current - (3 * step).month).end_of_month
    end
  end

  def get_month(date)
    date.strftime('%b, %Y')
  end
end
