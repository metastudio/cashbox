require 'rails_helper'

describe 'PUT /api/organizations/#/members/#' do
  let(:path) { "/api/organizations/#{organization.id}/members/#{user_member.id}" }

  let!(:owner) { create :user }
  let!(:admin) { create :user }
  let!(:user)  { create :user }
  let!(:organization) { create :organization }
  let!(:owner_member) { create :member, :owner, user: owner, organization: organization }
  let!(:admin_member) { create :member, :admin, user: admin, organization: organization }
  let!(:user_member)  { create :member, :user, user: user, organization: organization }

  let(:params) {
    { member: { role: 'admin' } }
  }

  context 'unauthenticated' do
    it { put(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as admin' do
    before { put path, params: params, headers: auth_header(admin) }

    it 'returns updated member' do
      expect(response).to be_success
      user_member.reload
      expect(json).to be_empty
      expect(user_member.role).to eq :admin
    end
  end

  context 'authenticated as owner' do
    before { put path, params: params, headers: auth_header(owner) }

    it 'returns updated member' do
      expect(response).to be_success
      user_member.reload
      expect(json).to be_empty
      expect(user_member.role).to eq :admin
    end

    context 'with wrong params' do
      let(:params) {
        { member: { role: 'wrong' } }
      }

      it 'returns error' do
        expect(response).to_not be_success
        expect(json).to include "role" => ["is not included in the list"]
      end
    end
  end

  context 'authenticated as user' do
    before { put path, params: params, headers: auth_header(user) }

    it 'returns error' do
      expect(response).to be_forbidden
      expect(json['error']).to include 'You are not authorized to perform this action.'
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { put path, params: params, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_success
      expect(json).to be_empty
    end
  end
end
