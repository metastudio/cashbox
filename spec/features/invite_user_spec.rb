require 'spec_helper'

describe 'Invite process' do
  let(:admin_member) { create :member, :admin }
  let(:email)        { generate :email }
  let(:long_email)   { 'gBLHc52d2DHKm5EdfM6NYZQ6r7ZgVqjrD3Dxg7K2FUfLefa4Cukr6zuBRgHyN2wTFZuast8ZqSmPQKsuwfr8NUat5W7mApJxGuK5t2MYAFmcaLEEQupubXF497nxWp4zLYzhm3rhYtCqMSZvxFS2Az7psXCaPUdbEWhkmWJwGMS2RDJNtkH6ApJKXuyhwFknsMn6EdHMKCWjBTMbna95dzwUqafr6gDXhs3dnwC2fxMbtqNWRjj8DChdTPhSLpd3MhLth4Y2TpVh9h9gqkrnTRVpHj7sbkT575TmPuUWQKStmCYGsV27dJ4QtmLx7Z6evDG2KX3UjS8azGTfgyzdRwZQTT9DncDhM7eKuRS5krAH6gr3QKhB6RrjQQpjmKzMDQ9rg6vCKTxkmLgVddJePq4QKyFeNTAJPnGsKJSfUEhZDGqGgLxmwpmfumjZbf689cYd3SgNfxQCNUrqNqPPFNcHbvvdKnEqaav8YNcYFJmsAdQKE3hP2kqyLqVvy8PY@mail.ru'}
  let(:invalid_email) { 'gBLHc52d2DHKm5EdfM6NYZQ6r7ZgVqjr' }

  before do
    sign_in admin_member.user
    visit new_invitation_path
  end

  context 'a new user' do
    before do
      fill_in 'Email', with: email
      select 'Admin', from: 'Role'
      click_on 'Invite'
    end

    it { expect(page).to have_content('An invitation was created successfully') }
    it { expect(current_path).to eq new_invitation_path }

    context 'when an invitation has already been sent' do
      before do
        visit new_invitation_path
        fill_in 'Email', with: email
        select 'Admin', from: 'Role'
        click_on 'Invite'
      end

      it { expect(page).to have_content('An invitation has already been sent') }
    end

    context 'when created invite' do
      subject { Invitation.last }

      it { expect(subject.email).to eq email }
      it { expect(subject.invited_by_id).to eq admin_member.id  }
    end

    describe 'sent email' do
      before { open_email email }

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
end
