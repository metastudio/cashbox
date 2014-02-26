require 'spec_helper'

describe "create organization" do
  let(:user) { create :user }
  let(:organization_name) { generate :organization_name }

  subject{ page }

  before :each do
    sign_in user
    visit new_organization_path
    fill_in 'Name', with: organization_name
    click_on 'Create Organization'
  end

  context "with valid data" do
    it "creates organization" do
      expect(Organization).to be_exists(name: organization_name)
    end

    it "shows success message" do
      expect(subject).to have_flash_message("Organization was successfully created.")
    end
  end

  context "without name" do
    let(:organization_name) { nil }

    it "doesn't create organization" do
      expect(Organization).to_not be_exists(name: organization_name)
    end

    it "shows error for name field" do
      expect(subject).to have_inline_error("can't be blank").for_field("Name")
    end
  end
end
