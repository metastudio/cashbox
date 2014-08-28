require 'spec_helper'

describe 'Role creation' do
  let(:user1) { create :user }
  let!(:user2) { create :user }
  let!(:organization) { create :organization, with_user: user1 }

  before do
    sign_in user1
    visit new_role_path
    select 'owner', from: 'Name'
    select user2.full_name, from: 'User'
    click_on 'Create Role'
  end

  it { expect(page).to have_content 'Role was created successfully' }
end
