require 'rails_helper'

describe 'DELETE /api/organizations/#/members/#' do
  let!(:owner) { create :user }
  let!(:admin) { create :user }
  let!(:user)  { create :user }
  let!(:organization) { create :organization }
  let!(:owner_member) { create :member, :owner, user: owner, organization: organization }
  let!(:admin_member) { create :member, :admin, user: admin, organization: organization }
  let!(:user_member)  { create :member, :user, user: user, organization: organization }

  context 'delete user member' do
    let(:path) { "/api/organizations/#{organization.id}/members/#{user_member.id}" }

    context 'unauthenticated' do
      it { delete(path) && expect(response).to(be_unauthorized) }
    end

    context 'authenticated as admin' do
      before { delete path, headers: auth_header(admin) }

      it 'delete member' do
        expect(response).to be_successful
        expect(response.body).to be_empty

        expect(Member.where(role: 'user').all).to eq []
      end
    end

    context 'authenticated as owner' do
      before { delete path, headers: auth_header(owner) }

      it 'delete member' do
        expect(response).to be_successful
        expect(response.body).to be_empty

        expect(Member.where(role: 'user').all).to eq []
      end
    end

    context 'authenticated as user' do
      before { delete path, headers: auth_header(user) }

      it 'returns error' do
        expect(response).to be_forbidden
        expect(json['error']).to include 'You are not authorized to perform this action.'
      end
    end

    context 'authenticated as wrong user' do
      let!(:wrong_user) { create :user }

      before { delete path, headers: auth_header(wrong_user) }

      it 'returns error' do
        expect(response).to_not be_successful
        expect(json).to be_empty
      end
    end
  end

  context 'delete owner member' do
    let(:path) { "/api/organizations/#{organization.id}/members/#{owner_member.id}" }

    context 'unauthenticated' do
      it { delete(path) && expect(response).to(be_unauthorized) }
    end

    context 'authenticated as admin' do
      before { delete path, headers: auth_header(admin) }

      it 'returns error' do
        expect(response).to be_forbidden
        expect(json['error']).to include 'You are not authorized to perform this action.'
      end
    end

    context 'authenticated as owner' do
      before { delete path, headers: auth_header(owner) }

      it 'returns error' do
        expect(response).to be_forbidden
        expect(json['error']).to include 'You are not authorized to perform this action.'
      end
    end

    context 'authenticated as user' do
      before { delete path, headers: auth_header(user) }

      it 'returns error' do
        expect(response).to be_forbidden
        expect(json['error']).to include 'You are not authorized to perform this action.'
      end
    end

    context 'authenticated as wrong user' do
      let!(:wrong_user) { create :user }

      before { delete path, headers: auth_header(wrong_user) }

      it 'returns error' do
        expect(response).to_not be_successful
        expect(json).to be_empty
      end
    end
  end

  context 'delete admin member' do
    let(:path) { "/api/organizations/#{organization.id}/members/#{admin_member.id}" }

    context 'unauthenticated' do
      it { delete(path) && expect(response).to(be_unauthorized) }
    end

    context 'authenticated as admin' do
      before { delete path, headers: auth_header(admin) }

      it 'returns error' do
        expect(response).to be_forbidden
        expect(json['error']).to include 'You are not authorized to perform this action.'
      end
    end

    context 'authenticated as owner' do
      before { delete path, headers: auth_header(owner) }

      it 'delete member' do
        expect(response).to be_successful
        expect(response.body).to be_empty

        expect(Member.where(role: 'admin').all).to eq []
      end
    end

    context 'authenticated as user' do
      before { delete path, headers: auth_header(user) }

      it 'returns error' do
        expect(response).to be_forbidden
        expect(json['error']).to include 'You are not authorized to perform this action.'
      end
    end

    context 'authenticated as wrong user' do
      let!(:wrong_user) { create :user }

      before { delete path, headers: auth_header(wrong_user) }

      it 'returns error' do
        expect(response).to_not be_successful
        expect(json).to be_empty
      end
    end
  end
end
