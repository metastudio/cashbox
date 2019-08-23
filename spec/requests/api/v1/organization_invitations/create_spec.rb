require 'rails_helper'

describe 'POST /api/organizations/#/organization_invitations' do
  let(:path) { "/api/organizations/#{organization.id}/organization_invitations" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:member) { create :member, :owner, user: owner, organization: organization }
  let(:params) {
    {
      organization_invitation: {
        email: 'new@mail.ru',
        role:  'user'
      }
    }
  }

  context 'when user not authenticated' do
    it { post(path) && expect(response).to(be_unauthorized) }
  end

  context 'when user authenticated as owner' do
    before { post path, params: params, headers: auth_header(owner) }

    it 'create the organization invitation' do
      expect(response).to be_successful

      expect(json).to include(
        'id' => OrganizationInvitation.last.id,
        'email' => 'new@mail.ru',
        'role'  => "user",
        'invited_by' => {
          'id'              => member.id,
          'role'            => member.role,
          'last_visited_at' => member.last_visited_at,
          'user' => {
            'id'           => owner.id,
            'email'        => owner.email,
            'full_name'    => owner.full_name,
            'phone_number' => owner.profile.phone_number
          }
        }
      )
    end
  end

  context 'when user authenticated as user' do
    before { post path, params: params, headers: auth_header(user) }

    it 'create the organization invitation' do
      expect(response).not_to be_successful
    end
  end

  context 'when user authenticated as wrong user' do
    let!(:wrong_user) { create :user }
    before { post path, params: params, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_successful
      expect(json).to be_empty
    end
  end
end
