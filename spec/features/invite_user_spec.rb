require 'spec_helper'

describe 'Invite user' do
  let(:admin) { create :user, :admin }
  let(:email) { generate :email }
  let(:token) { generate :password }

  before do
    allow(InvitationsController.any_instance).to receive(:invitation_token).and_return(token)
    sign_in admin
    visit new_invitation_path
  end

  describe 'Invite a new user' do
    before do
      fill_in 'Email', with: email
      click_on 'Invite'
    end

    describe 'Created user' do
      subject { User.last }

      it { expect(subject.email).to eq email }
      it { expect(subject.full_name).to eq 'Please change' }
    end

    describe 'Created invite' do
      subject { Invitation.last }

      it { expect(subject.user_id).to eq User.last.id }
      it { expect(subject.organization_id).to eq admin.organizations.first.id }
    end

    describe 'Sent email' do
      before { open_email email }

      it { expect(current_email).to have_content("You are invited to #{admin.organizations.first.name}")  }
      it { expect(current_email).to have_content("Your temporary password is #{Invitation.last.token}")  }
      it { expect(current_email).to have_link("Accept")  }
    end
  end

  describe 'Invite an existing user' do
    pending
  end
end
