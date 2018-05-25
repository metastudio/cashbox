require 'rails_helper'

describe 'unsubscribes' do
  let!(:organization) { create :organization }
  let!(:admin_member) { create :member, :admin, organization: organization }
  let!(:organization2) { create :organization, owner: admin_member.user }
  let(:email)        { generate :email }

  before do
    sign_in admin_member.user
    visit new_organization_invitation_path
    fill_in 'Email', with: email
    select 'Admin', from: 'Role'
    click_on 'Invite'
  end

  it 'has working link for unsubscribe' do
    open_email email
    expect(current_email).to have_link('Unsubscribe')
    current_email.click_link 'Unsubscribe'
    expect(page).to have_content("Email #{email} was unsubscribed. We are sorry that you have decided to unsubscribe. We are waiting for you back.")
  end

  context 'when user unsubscribe' do
    before do
      open_email email
      current_email.click_link 'Unsubscribe'
      ActionMailer::Base.deliveries.clear
      sign_out
      sign_in admin_member.user
      click_on 'Change organization'

      page.has_css?("##{dom_id(admin_member.user.organizations.last, :switch)}")
      within "##{dom_id(admin_member.user.organizations.last, :switch)}" do
        click_on 'Switch'
      end
      visit new_organization_invitation_path
      fill_in 'Email', with: email
      select 'Admin', from: 'Role'
      click_on 'Invite'
    end

    it 'emails not sending' do
      expect(ActionMailer::Base.deliveries.count).to eq(0)
    end
  end
end
