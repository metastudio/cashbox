require 'rails_helper'

describe 'DELETE /api/organizations/#/organization_invitations/#' do
  let(:path) { "/api/organizations/#{organization.id}/organization_invitations/#{invitation.id}" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:member) { create :member, :owner, user: owner, organization: organization }
  let!(:invitation) { create :organization_invitation, invited_by: member }

  context 'when user is not authenticated' do
    it { delete(path) && expect(response).to(be_unauthorized) }
  end

  context 'when user is authenticated as owner' do
    before { delete path, headers: auth_header(owner) }

    it 'delete transaction' do
      expect(response).to be_success
      expect(response.body).to be_empty

      expect(OrganizationInvitation.all).to eq []
    end
  end

  context 'when user is authenticated as user' do
    before { delete path, headers: auth_header(user) }

    it 'delete transaction' do
      expect(response).not_to be_success
    end
  end

  context 'when user is authenticated as not member of organization' do
    let!(:wrong_user) { create :user }

    before { delete path, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_success
      expect(json).to be_empty
    end
  end
end
