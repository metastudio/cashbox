require 'rails_helper'

describe 'PUT /api/organizations/#/last_visit' do
  let(:path) { "/api/organizations/#{organization.id}/last_visit" }

  let!(:user)         { create :user }
  let!(:organization) { create :organization }
  let!(:member)       { create :member, :user, user: user, organization: organization, last_visited_at: nil }

  context 'unauthenticated' do
    it { put(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as user' do
    before { put path, params: {}, headers: auth_header(user) }

    it 'returns updated member' do
      expect(response).to be_success
      member.reload
      include(
        'id'              => member.id,
        'role'            => member.role,
        'last_visited_at' => member.last_visited_at.as_json,
      )
      expect(member.last_visited_at).to_not eq nil
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { put path, params: {}, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_success
      expect(json).to be_empty
    end
  end
end
