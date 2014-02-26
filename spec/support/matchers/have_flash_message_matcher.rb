RSpec::Matchers.define :have_flash_message do |message|
  match_for_should do |page|
    page.within('.flash-messages') do
      page.has_content?(message)
    end
  end

  match_for_should_not do |page|
    page.within('.flash-messages') do
      page.has__nocontent?(message)
    end
  end

  failure_message_for_should do |page|
    %Q{expected to have flash message "#{message}" in "#{page.text}"}
  end

  failure_message_for_should_not do |page|
    %Q{expected to not have flash message "#{message}" in "#{page.text}"}
  end

  description do
    %Q{have flash message "#{message}"}
  end
end
