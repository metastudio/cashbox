class RussianCentralBankSafe < Money::Bank::RussianCentralBank
  def exchange(fractional, rate, &block)
    ex = (fractional * BigDecimal(rate.to_s))
    if block_given?
      yield ex.to_f
    elsif @rounding_method
      @rounding_method.call(ex.to_f)
    else
      ex.to_d
    end
  end
end
