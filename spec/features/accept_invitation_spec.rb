require 'spec_helper'

describe 'Accept invitation' do
  let(:admin_member) { create :member, :admin }
  let(:email) { generate :email }
  let(:full_name) { generate :full_name }
  let(:password) { generate :password }
  let(:existing_user) { nil }

  before { clear_emails }

  context 'for a new user' do
    before do
      invite_new_user(admin_member.user, 'admin', email)
      sign_in existing_user if existing_user.present?
      open_email email
      current_email.click_link 'Accept'
      fill_in 'Full name', with: full_name
      fill_in 'Password', with: password
      click_on 'Submit'
    end

    subject { page }

    it { save_and_open_page; expect(subject).to have_content "You joined to #{admin_member.organization.name}" }
    it { expect(subject).to have_content "Sign out" }
    it "flags invitation as accepted" do
      expect(Invitation.last.accepted).to eq true
    end

    context 'a invited user already exists with different email and is logged in' do
      let(:existing_user) { create :user }

      it { expect(subject).to have_content "You joined to #{admin_member.organization.name}" }
      it { expect(subject).to have_content "Sign out" }
    end

    context 'invalid params' do
      let(:full_name) { nil }
      let(:password) { nil }

      it { expect(page).to have_inline_error("can't be blank").for_field('Full name') }
      it { expect(page).to have_inline_error("can't be blank").for_field('Password') }
    end
  end

  context 'for existing user' do
    let(:existing_user) { create :user, email: email }

    before do
      invite_new_user(admin_member.user, 'admin', email)
      sign_in existing_user
    end

    context do
      before do
        open_email email
        current_email.click_link 'Accept'
      end

      subject { page }

      it { expect(subject).to have_content "You joined to #{admin_member.organization.name}" }
      it { expect(subject).to have_content "Sign out" }
    end

    it "doesn't create a new user" do
      expect { open_email(email); current_email.click_link 'Accept' }.not_to change(User, :count)
    end

  end
end
