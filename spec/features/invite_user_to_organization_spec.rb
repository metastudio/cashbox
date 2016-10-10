require 'rails_helper'

describe 'Invite process' do
  let(:organization) { create :organization }
  let(:admin_member) { create :member, :admin, organization: organization }
  let(:email)        { generate :email }
  let(:long_email)   { 'gBLHc52d2DHKm5EdfM6NYZQ6r7ZgVqjrD3Dxg7K2FUfLefa4Cukr6zuBRgHyN2wTFZuast8ZqSmPQKsuwfr8NUat5W7mApJxGuK5t2MYAFmcaLEEQupubXF497nxWp4zLYzhm3rhYtCqMSZvxFS2Az7psXCaPUdbEWhkmWJwGMS2RDJNtkH6ApJKXuyhwFknsMn6EdHMKCWjBTMbna95dzwUqafr6gDXhs3dnwC2fxMbtqNWRjj8DChdTPhSLpd3MhLth4Y2TpVh9h9gqkrnTRVpHj7sbkT575TmPuUWQKStmCYGsV27dJ4QtmLx7Z6evDG2KX3UjS8azGTfgyzdRwZQTT9DncDhM7eKuRS5krAH6gr3QKhB6RrjQQpjmKzMDQ9rg6vCKTxkmLgVddJePq4QKyFeNTAJPnGsKJSfUEhZDGqGgLxmwpmfumjZbf689cYd3SgNfxQCNUrqNqPPFNcHbvvdKnEqaav8YNcYFJmsAdQKE3hP2kqyLqVvy8PY@mail.ru'}
  let(:invalid_email) { 'gBLHc52d2DHKm5EdfM6NYZQ6r7ZgVqjr' }

  before do
    sign_in admin_member.user
    visit new_organization_invitation_path
  end

  context 'a new user' do
    before do
      fill_in 'Email', with: email
      select 'Admin', from: 'Role'
      click_on 'Invite'
    end

    it { expect(page).to have_content('An invitation was created successfully') }
    it { expect(current_path).to eq new_organization_invitation_path }

    context 'when an invitation has already been sent' do
      before do
        visit new_organization_invitation_path
        fill_in 'Email', with: email
        select 'Admin', from: 'Role'
        click_on 'Invite'
      end

      it { expect(page).to have_content('An invitation has already been sent') }
    end

    context 'when created invite' do
      subject { OrganizationInvitation.last }

      it { expect(subject.email).to eq email }
      it { expect(subject.invited_by_id).to eq admin_member.id  }
    end

    describe 'sent email' do
      before do
        open_email email
      end

      it { expect(current_email).to have_content("You are invited to #{admin_member.organization.name} as admin")  }
      it { expect(current_email).to have_link 'Accept'}
    end
  end

  context "negative input" do
    context "long email" do
      before do
        fill_in 'Email', with: long_email
        select 'Admin', from: 'Role'
        click_on 'Invite'
      end

      it { expect(page).to have_content('too long')}
    end

    context "invalid format" do
      before do
        fill_in 'Email', with: invalid_email
        select 'Admin', from: 'Role'
        click_on 'Invite'
      end

      it { expect(page).to have_content('invalid format')}
    end
  end

  context "invite already created user" do
    let(:password) { SecureRandom.hex(10) }
    let(:user) { create :user, password: password }

    before do
      fill_in 'Email', with: user.email
      select 'Admin', from: 'Role'
      click_on 'Invite'
    end

    let(:invitation) { organization.invitations.last }

    it { expect(invitation.email).to eq(user.email) }
    it { expect(invitation.accepted).to eq(false) }


    context "logged in" do
      it "redirected to organization path" do
        sign_out
        sign_in user
        visit accept_invitation_path(invitation.token)
        expect(current_path).to eq root_path
        expect(page).to have_content("You joined #{organization.name}.")
      end
    end

    context "logged in under another user" do
      it "redirected to new session path" do
        visit accept_invitation_path(invitation.token)
        expect(current_path).to eq new_user_session_path
        visit new_user_session_path
        within('#new_user') do
          fill_in 'Email', with: user.email
          fill_in 'Password', with: user.password
          click_button 'Sign in'
        end
        expect(organization.invitations.find(invitation.id).accepted).to eq true
      end
    end

    context "not logged in" do
      it "redirect to new session path" do
        sign_out
        visit accept_invitation_path(invitation.token)
        expect(current_path).to eq new_user_session_path
        visit new_user_session_path
        within('#new_user') do
          fill_in 'Email', with: user.email
          fill_in 'Password', with: user.password
          click_button 'Sign in'
        end
        expect(current_path).to eq root_path
        expect(organization.invitations.find(invitation.id).accepted).to eq true
      end
    end
  end
end
