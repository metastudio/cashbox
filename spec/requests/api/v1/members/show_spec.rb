# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/members/#' do
  let(:path) { api_organization_member_path(org, member) }

  let(:user) { create :user }
  let!(:org) { create :organization }
  let!(:member) { create :member, :user, user: user, organization: org }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated' do
    before { get path, headers: auth_header(user) }

    context 'user belongs to member\'s organization' do
      it 'returns invoice' do
        expect(response).to be_success

        expect(json).to include(
          'id'              => member.id,
          'role'            => member.role,
          'last_visited_at' => member.last_visited_at.as_json,
        )
      end
    end

    context "user doesn't belong to member's org" do
      let!(:member) { create :member, user: user }

      it 'returns error' do
        expect(response).to be_not_found
        expect(json).to be_empty
      end
    end
  end
end
