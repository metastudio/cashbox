require 'rails_helper'

describe 'GET /api/organizations/#/organization_invitations' do
  let(:path) { "/api/organizations/#{organization.id}/organization_invitations" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:member) { create :member, :owner, user: owner, organization: organization }
  let!(:invitation) { create :organization_invitation, invited_by: member }

  context 'without authenticated user' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'with authenticated owner' do
    before { get path, headers: auth_header(owner) }

    it 'returns organization invitations' do
      returns_organization_invitations
    end
  end

  context 'with authenticated user' do
    before { get path, headers: auth_header(user) }

    it 'returns organization invitations' do
      returns_organization_invitations
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { get path, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_successful
      expect(json).to be_empty
    end
  end
end
