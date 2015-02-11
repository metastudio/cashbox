shared_context 'organization with roles' do
  let(:owner) { create :user }
  let(:admin) { create :user }
  let(:user)  { create :user }
  let(:organization)  { create :organization }
  let!(:owner_member) { create :member, :owner, user: owner, organization: organization }
  let!(:admin_member) { create :member, :admin, user: admin, organization: organization }
  let!(:user_member)  { create :member, :user, user: user, organization: organization }
end
