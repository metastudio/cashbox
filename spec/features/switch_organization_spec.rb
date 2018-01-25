require 'rails_helper'

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
      click_on 'Change organization'
      within "##{dom_id(user.organizations.last, :switch)}" do
        click_on 'Switch'
      end
    end

    it "displays selected organization" do
      within "#current_organization" do
        expect(subject).to have_text user.organizations.last.name
      end
    end
  end
end
