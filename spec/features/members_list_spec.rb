require 'spec_helper'

describe 'Members list' do
  let(:user)   { create :user }
  let(:org)    { create :organization, with_user: user }
  let!(:member) { create :member, :owner, user: user }

  before do
    sign_in user
    visit members_path
  end

  subject { page }

  it "has New Invitation button" do
    expect(page).to have_link('New Invitation')
  end

  it 'shows members table' do
    within 'tbody.members' do
      expect(page).to have_selector('td', text: member.user_full_name)
      expect(page).to have_selector('td', text: member.user.email)
      expect(page).to have_selector('td', text: member.role)
    end
  end
end

