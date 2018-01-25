module FeatureMacros
  module Organization
    def create_organization(organization_name)
      visit new_organization_path
      fill_in 'Name', with: organization_name
      click_on 'Create Organization'
    end
  end
end

RSpec.configure do |config|
  config.include FeatureMacros::Organization, type: :feature
end
