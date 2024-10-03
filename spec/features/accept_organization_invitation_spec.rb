require 'rails_helper'

describe 'Accept invitation' do
  let(:admin_member) { create :member, :admin }
  let(:email)        { generate :email }
  let(:full_name)    { generate :full_name }
  let(:password)     { generate :password }
  let(:existing_user){ nil }

  before { clear_emails }

  context 'for a new user' do
    before do
      invite_user(admin_member.user, 'admin', email)
      open_email email
      current_email.click_link 'Accept'
      fill_in 'Full name', with: full_name
      fill_in 'Password', with: password
      fill_in 'Password confirmation', with: password
      click_on 'Submit'
    end

    it "flags invitation as accepted and create a User" do
      expect(OrganizationInvitation.last.accepted).to eq true
      expect(page).to have_content "You joined #{admin_member.organization.name}"
      expect(page).to have_content "Sign out"
      # inviter and invited
      expect(User.count).to eq 2
    end

    context 'with invalid params' do
      let(:full_name) { nil }
      let(:password) { nil }

      it 'return error on fields' do
        expect(page).to have_inline_error("can't be blank").for_field('Full name')
        expect(page).to have_inline_error("can't be blank").for_field('Password')
      end
    end
  end

  context 'for an existing user' do
    let!(:existing_user) { create :user, email: email }

    before do
      invite_user(admin_member.user, 'admin', existing_user.email)
      open_email email
      current_email.click_link 'Accept'
    end

    context 'when signed in' do
      let(:invitation) { existing_user.invitations.last }
      before do
        visit new_user_session_path

        # We have to do SignIn here without using sign_in helper, because we show another flash message for invited user
        within('#new_user') do
          fill_in 'Email', with: existing_user.email
          fill_in 'Password', with: existing_user.password
          click_button 'Sign in'
        end
      end

      it 'has congratulation and sing out link' do
        expect(page).to have_content "You joined #{admin_member.organization.name}"
        expect(page).to have_content "Sign out"
      end
    end

    it "page has sign in link and doesn't create a new user" do
      expect(page).to have_content "Sign in"
      expect { open_email(email); current_email.click_link 'Accept' }.not_to change{ User.count }
    end
  end

  context 'with invalid token' do
    let(:existing_user) { create :user, :with_organization }
    let(:invitation) { create :organization_invitation, email: existing_user.email, member: admin_member}
    before do
      sign_in existing_user
      token = SecureRandom.urlsafe_base64(nil, false)
      visit accept_invitation_path(token: token)
    end

    it 'show error msg' do
      expect(page).to have_flash_message('Bad invitation token')
    end
  end
end
