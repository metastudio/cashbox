RSpec::Matchers.define :have_inline_error do |expected|
  define_method :for_field do |field|
    @field = field
    self
  end

  match do |page|
    within(@field) do
      page.has_content?(expected)
    end
  end

  match_when_negated do |page|
    within_fieldset(@field) do
      page.has_no_content?(expected)
    end
  end

  failure_message do |page|
    %Q{expected to have inline error \"#{expected}\" for field \"#{@field || @field_name}\"}
  end

  failure_message_when_negated do |page|
    %Q{expected to not have inline error \"#{expected}\" for field \"#{@field || @field_name}\"}
  end

  description do
    %Q{have inline error \"#{expected}\" for field \"#{@field || @field_name}\"}
  end
end
