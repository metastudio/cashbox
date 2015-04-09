RSpec::Matchers.define :have_image do |image_url|
  match do |page|
    page.has_selector?(%Q{img[src="#{image_url}"]})
  end

  match_when_negated do |page|
    page.has_no_selector?(%Q{img[src="#{image_url}"]})
  end

  failure_message do |page|
    %Q{expected to have image with url \"#{image_url}\""}
  end

  failure_message_when_negated do |page|
    %Q{expected to not have image with url \"#{image_url}\""}
  end

  description do
    %Q{have image with url \"#{image_url}\""}
  end
end
