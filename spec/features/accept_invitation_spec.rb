require 'spec_helper'

describe 'Accept invitation' do
  let(:admin_member) { create :member, :admin }
  let(:email)        { generate :email }
  let(:full_name)    { generate :full_name }
  let(:password)     { generate :password }
  let(:existing_user){ nil }
  let(:accept)       { 'Accept' }

  before { clear_emails }

  context 'for a new user' do
    before do
      invite_user(admin_member.user, 'admin', email)
      sign_in existing_user if existing_user.present?
      open_email email
      current_email.click_link accept
      fill_in 'Full name', with: full_name
      fill_in 'Password', with: password
      click_on 'Submit'
    end

    it { expect(page).to have_content "You joined #{admin_member.organization.name}" }
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

  context 'for an existing user' do
    let!(:existing_user) { create :user, email: email }

    before do
      invite_user(admin_member.user, 'admin', existing_user)
    end

    context do
      before do
        open_email email
        current_email.click_link accept
      end

      subject { page }

      it { expect(subject).to have_content "Sign in" }

      context 'when signed in' do
        before do
          sign_in existing_user
        end

        it { expect(subject).to have_content "You joined #{admin_member.organization.name}" }
        it { expect(subject).to have_content "Sign out" }
      end
    end

    it "doesn't create a new user" do
      expect { open_email(email); current_email.click_link accept }.not_to change{ User.count }
    end
  end

  context 'with invalid token' do
    let(:existing_user) { create :user, :with_organization }
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
