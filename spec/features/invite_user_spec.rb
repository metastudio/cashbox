require 'spec_helper'

describe 'Invite process' do
  let(:admin_member) { create :member, :admin }
  let(:email)        { generate :email }

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
end
