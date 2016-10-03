require 'rails_helper'

describe 'Invite process' do
  let(:organization) { create :organization }
  let(:admin_member) { create :member, :admin, organization: organization }
  let(:email)        { generate :email }

  before do
    sign_in admin_member.user
    visit new_invitation_path
  end

  context 'a new user' do
    before do
      fill_in 'Email', with: email
      click_on 'Invite'
    end

    it { expect(page).to have_content('An invitation was created successfully') }
    it { expect(current_path).to eq new_invitation_path }


    describe 'sent email' do
      before do
        Notification.deliver_all
        open_email email
      end

      it { expect(current_email).to have_content("You are invited to CASHBOX")  }
      it { expect(current_email).to have_link 'Accept'}
    end
  end

  context "invite already created user" do
    let(:password) { SecureRandom.hex(10) }
    let(:user) { create :user, password: password }

    before do
      fill_in 'Email', with: user.email
      click_on 'Invite'
    end

    it "not invite already creted user" do
      expect(page).to have_content("User already registered in system")
    end
  end
end
