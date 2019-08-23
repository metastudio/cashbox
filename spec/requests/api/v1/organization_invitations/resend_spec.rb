require 'rails_helper'

describe 'POST /api/organizations/#/organization_invitations/#/resend' do
  let(:path) { "/api/organizations/#{organization.id}/organization_invitations/#{invitation.id}/resend" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:member) { create :member, :owner, user: owner, organization: organization }
  let!(:invitation) { create :organization_invitation, invited_by: member }

  context 'when user is not authenticated' do
    it { post(path) && expect(response).to(be_unauthorized) }
  end

  context 'when user is authenticated as owner' do
    before do
      ActionMailer::Base.deliveries = []
      post path, headers: auth_header(owner)
    end

    it 'resend transaction' do
      expect(response).to be_successful
      expect(response.body).to be_empty

      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end

  context 'when user is authenticated as user' do
    before { post path, headers: auth_header(user) }

    it 'returns error' do
      expect(response).not_to be_successful
    end
  end

  context 'when user is authenticated as not member of organization' do
    let!(:wrong_user) { create :user }

    before { post path, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_successful
      expect(json).to be_empty
    end
  end
end
