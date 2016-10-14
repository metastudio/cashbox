require 'rails_helper'

describe 'Accept invitation' do
  let(:admin_member) { create :member, :admin }
  let(:email)        { generate :email }
  let(:full_name)    { generate :full_name }
  let(:password)     { generate :password }

  before { clear_emails }

  context 'for a new user' do
    before do
      sign_in admin_member.user
      visit new_invitation_path
      fill_in 'Email', with: email
      click_on 'Invite'
      sign_out
      open_email email
      current_email.click_link 'Accept'
      fill_in 'Full name', with: full_name
      fill_in 'Password', with: password
      fill_in 'Password confirmation', with: password
      click_on 'Submit'
    end

    it { expect(page).to have_content "You joined CASHBOX" }
    it { expect(page).to have_content "Sign out" }
    it "flags invitation as accepted" do
      expect(Invitation.last.accepted).to eq true
    end

    it 'create a User' do
      # inviter and invited
      expect(User.count).to eq 2
    end

    context 'invalid params' do
      let(:full_name) { nil }
      let(:password) { nil }

      it { expect(page).to have_inline_error("can't be blank").for_field('Full name') }
      it { expect(page).to have_inline_error("can't be blank").for_field('Password') }
    end
  end
end
