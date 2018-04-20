# == Schema Information
#
# Table name: invitations
#
#  id            :integer          not null, primary key
#  token         :string(255)      not null
#  email         :string(255)      not null
#  role          :string
#  accepted      :boolean          default(FALSE)
#  invited_by_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#  type          :string
#

require 'rails_helper'

describe InvitationBase do
  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  context 'validation' do
    it { should validate_presence_of(:email) }
    it do
      should validate_length_of(:email)
       .is_at_most(255)
       .with_message("too long")
    end
    it { should allow_value('foo@mail.ru').for(:email) }
    it { should_not allow_value('foomail').for(:email) }
  end

  context 'scopes' do
    context 'active' do
      let!(:active_invitation) { create :organization_invitation }
      let!(:unactive_invitation) { create :organization_invitation, accepted: true }

      it 'contain active invitation' do
        expect(InvitationBase.active).to include(active_invitation)
      end

      it 'not contain unactive invitation' do
        expect(InvitationBase.active).to_not include(unactive_invitation)
      end
    end

    context 'unanswered' do
      let!(:unanswered_invitation) { create :organization_invitation, created_at: 2.weeks.ago }
      let!(:answered_invitation) { create :organization_invitation, accepted: true, created_at: 2.weeks.ago }
      let!(:today_invitation) { create :organization_invitation }

      it 'contain unanswered invitation' do
        expect(InvitationBase.unanswered).to include(unanswered_invitation)
      end

      it 'not contain unactive invitation' do
        expect(InvitationBase.unanswered).to_not include(answered_invitation, today_invitation)
      end
    end
  end

  context '#self.resend_unanswered' do
    let!(:unanswered_invitation) { create :organization_invitation, created_at: 2.weeks.ago }

    before { InvitationBase.resend_unanswered }

    it 'have 2 delivery emails' do
      # one init email
      # two unanswered email
      expect(ActionMailer::Base.deliveries.count).to eq(2)
    end
  end
end
