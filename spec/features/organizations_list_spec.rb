require 'rails_helper'

describe 'Organizations list' do
  let!(:user) { create :user, :with_organizations }
  let(:organizations) { user.organizations }

  before do
    sign_in user
    visit organizations_path
  end

  subject { page }

  it "has create organization btn and shows table with appropriate content" do
    expect(page).to have_link('New Organization')
    organizations.each do |organization|
      within "tbody" do
        expect(page).to have_selector('td', text: organization.name)
        expect(page).to have_selector('td',
          text: organization.owners.map(&:email).join(', '))
        expect(page).to have_link('Show')
      end
    end
  end
end

