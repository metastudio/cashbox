RSpec::Matchers.define :have_flash_message do |message|
  def flash_message_selector
    '.flash-messages'
  end

  match do |page|
    page.within(flash_message_selector) do
      page.has_content?(message)
    end
  end

  match_when_negated do |page|
    page.within(flash_message_selector) do
      page.has_no_content?(message)
    end
  end

  failure_message do |page|
    %Q{expected to have flash message "#{message}" in "#{page.find(flash_message_selector).try(:text)}"}
  end

  failure_message_when_negated do |page|
    %Q{expected to not have flash message "#{message}" in "#{page.find(flash_message_selector).try(:text)}"}
  end

  description do
    %Q{have flash message "#{message}"}
  end
end
