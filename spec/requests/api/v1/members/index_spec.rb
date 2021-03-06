require 'rails_helper'

describe 'GET /api/organizations/#/members' do
  let(:path) { "/api/organizations/#{organization.id}/members" }

  let!(:owner) { create :user }
  let!(:admin) { create :user }
  let!(:user)  { create :user }
  let!(:organization) { create :organization }
  let!(:owner_member) { create :member, :owner, user: owner, organization: organization }
  let!(:admin_member) { create :member, :admin, user: admin, organization: organization }
  let!(:user_member)  { create :member, :user, user: user, organization: organization }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as admin' do
    before { get path, headers: auth_header(admin) }

    it 'returns members' do
      expect(response).to be_successful

      expect(json).to include(
        'id'              => owner_member.id,
        'role'            => owner_member.role,
        'last_visited_at' => owner_member.last_visited_at.as_json,
        'user'            => { 'id'=>owner.id, 'email'=>owner.email, 'full_name'=>owner.full_name, 'phone_number'=>nil }
      )
      expect(json).to include(
        'id'              => admin_member.id,
        'role'            => admin_member.role,
        'last_visited_at' => admin_member.last_visited_at.as_json,
        'user'            => { 'id'=>admin.id, 'email'=>admin.email, 'full_name'=>admin.full_name, 'phone_number'=>nil }
      )
      expect(json).to include(
        'id'              => user_member.id,
        'role'            => user_member.role,
        'last_visited_at' => user_member.last_visited_at.as_json,
        'user'            => { 'id'=>user.id, 'email'=>user.email, 'full_name'=>user.full_name, 'phone_number'=>nil }
      )
    end
  end

  context 'authenticated as owner' do
    before { get path, headers: auth_header(owner) }

    it 'returns members' do
      expect(response).to be_successful

      expect(json).to include(
        'id'              => owner_member.id,
        'role'            => owner_member.role,
        'last_visited_at' => owner_member.last_visited_at.as_json,
        'user'            => { 'id'=>owner.id, 'email'=>owner.email, 'full_name'=>owner.full_name, 'phone_number'=>nil }
      )
      expect(json).to include(
        'id'              => admin_member.id,
        'role'            => admin_member.role,
        'last_visited_at' => admin_member.last_visited_at.as_json,
        'user'            => { 'id'=>admin.id, 'email'=>admin.email, 'full_name'=>admin.full_name, 'phone_number'=>nil }
      )
      expect(json).to include(
        'id'              => user_member.id,
        'role'            => user_member.role,
        'last_visited_at' => user_member.last_visited_at.as_json,
        'user'            => { 'id'=>user.id, 'email'=>user.email, 'full_name'=>user.full_name, 'phone_number'=>nil }
      )
    end
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(user) }

    it 'returns members' do
      expect(response).to be_successful

      expect(json).to include(
        'id'              => owner_member.id,
        'role'            => owner_member.role,
        'last_visited_at' => owner_member.last_visited_at.as_json,
        'user'            => { 'id'=>owner.id, 'email'=>owner.email, 'full_name'=>owner.full_name, 'phone_number'=>nil }
      )
      expect(json).to include(
        'id'              => admin_member.id,
        'role'            => admin_member.role,
        'last_visited_at' => admin_member.last_visited_at.as_json,
        'user'            => { 'id'=>admin.id, 'email'=>admin.email, 'full_name'=>admin.full_name, 'phone_number'=>nil }
      )
      expect(json).to include(
        'id'              => user_member.id,
        'role'            => user_member.role,
        'last_visited_at' => user_member.last_visited_at.as_json,
        'user'            => { 'id'=>user.id, 'email'=>user.email, 'full_name'=>user.full_name, 'phone_number'=>nil }
      )
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
