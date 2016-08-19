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
      "Fourtrh quarter of #{year}"
    end
  end

  def get_year(date)
    date.split(', ').last
  end

end