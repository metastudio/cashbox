require 'spec_helper'

describe 'Switch organization' do
  let(:user) { create :user, :with_organizations }

  before do
    sign_in user
  end

  subject { page }

  it "displays first organization as current initially" do
    within "#current_organization" do
      expect(subject).to have_text user.organizations.first.name
    end
  end

  context 'switch organization' do
    before do
      within "#switch_organization" do
        click_on user.organizations.last.name
      end
    end

    it "displays selected organization" do
      within "#current_organization" do
        expect(subject).to have_text user.organizations.last.name
      end
    end
  end
end
