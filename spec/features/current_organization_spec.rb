require 'spec_helper'

describe "current orgranization" do
  let(:user) { create :user }

  subject{ page }

  before :each do
    sign_in user
  end

  context "for user who is not in any organization" do
    it "shows a message to create a new organization" do
      expect(subject).to have_flash_message("You don't have any organization. Create a new one.")
    end

    it "redirects to new organization form" do
      expect(subject).to have_content("New organization")
    end
  end

  context "for user who is in organization and came for the first time" do
    let(:user) { create :user, :with_organization }

    it "selects first available organization" do
      within("#current_organization") do
        expect(subject).to have_content(user.organizations.first.name)
      end
    end
  end

  context "for user who select organization" do
    let(:user) { create :user, :with_organizations }

    before :each do
      within '#switch_organization' do
        click_link user.organizations.last.name
      end
    end

    it "see organization that was selected" do
      within("#current_organization") do
        expect(subject).to have_content(user.organizations.last.name)
      end
    end
  end
end
