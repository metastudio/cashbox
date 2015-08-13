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
      click_on 'Change organization'
      within "##{dom_id(user.organizations.last, :switch)}" do
        click_button 'Switch'
      end
    end

    it "see organization name" do
      within("#current_organization") do
        expect(subject).to have_content(user.organizations.last.name)
      end
    end

    it "see organization that was selected before sign out" do
      pending 'has not implemneted yet'
      sign_out
      sign_in user

      within("#current_organization") do
        expect(subject).to have_content(user.organizations.last.name)
      end
    end
  end
end
