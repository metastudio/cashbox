RSpec::Matchers.define :have_image do |image_url|
  match_for_should do |page|
    page.has_selector?(%Q{img[src="#{image_url}"]})
  end

  match_for_should_not do |page|
    page.has_no_selector?(%Q{img[src="#{image_url}"]})
  end

  failure_message_for_should do |page|
    %Q{expected to have image with url \"#{image_url}\""}
  end

  failure_message_for_should_not do |page|
    %Q{expected to not have image with url \"#{image_url}\""}
  end

  description do
    %Q{have image with url \"#{image_url}\""}
  end
end
