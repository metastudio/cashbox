require 'rails_helper'

describe 'unsubscribes'  do
  let!(:invitation) { create :organization_invitation }
  Notification.deliver_all

  it 'create 2 notification' do
    expect(Notification.count).to eq(2)
  end

  context 'user prohibited email notification' do
    let!(:unsubscribe) { Unsubscribe.find_or_create_by(email: invitation.user.email) }

    before do
      visit activate_unsubscribe_path(unsubscribe.token)
    end

    it 'has sad treatment' do
      expect(page).to have_content("Email #{invitation.user.email} was unsubscribed. We are sorry that you have decided to unsubscribe. We are waiting for you back.")
    end

    it 'dissallow notification sending' do
      expect(Notification.allowed?(invitation.user.email)).to eq(false)
    end
  end
end
