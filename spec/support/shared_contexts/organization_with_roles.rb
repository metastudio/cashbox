shared_context 'organization with roles' do
  let(:owner) { create :user }
  let(:admin) { create :user }
  let(:user) { create :user }
  let!(:ordinary_user) { create :user }
  let(:organization) { create :organization }
  let!(:owner_member) { create :member, user: owner, organization: organization, role: 'owner' }
  let!(:admin_member) { create :member, user: admin, organization: organization, role: 'admin' }
  let!(:user_member) { create :member, user: user, organization: organization, role: 'user' }
end
