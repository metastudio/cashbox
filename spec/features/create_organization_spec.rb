require 'rails_helper'

describe "create organization" do
  let(:user) { create :user }
  let(:organization_name) { generate :organization_name }

  subject{ create_organization(organization_name); page }

  before :each do
    sign_in user
  end

  context "with valid data" do
    it "creates organization and member" do
      create_organization(organization_name)
      expect(Organization).to be_exists(name: organization_name)
      expect(page).to have_flash_message("Organization was successfully created.")
      expect(Member.count).to eq(1)
      expect(Member.last.role).to eq 'owner'
    end
  end

  context "without name" do
    let(:organization_name) { nil }

    it "doesn't create organization and shows error for name field" do
      create_organization(organization_name)
      expect(Organization).to_not be_exists(name: organization_name)
      expect(page).to have_inline_error("can't be blank").for_field("Name")
    end
  end
end
