require 'spec_helper'

describe RolePolicy do
  shared_examples 'proper permitting' do
    it { expect(subject).to permit(owner, owner_role) }
    it { expect(subject).to permit(owner, admin_role) }
    it { expect(subject).to permit(owner, user_role) }

    it { expect(subject).not_to permit(admin, owner_role) }
    it { expect(subject).to permit(admin, admin_role) }
    it { expect(subject).to permit(admin, user_role) }

    it { expect(subject).not_to permit(user, owner_role) }
    it { expect(subject).not_to permit(user, admin_role) }
    it { expect(subject).not_to permit(user, user_role) }
  end

  let(:owner) { create :user }
  let(:admin) { create :user }
  let(:user) { create :user }
  let(:ordinary_user) { create :user }
  let(:organization) { create :organization }
  let!(:owner_role) { create :role, :owner, user: owner, organization: organization }
  let!(:admin_role) { create :role, :admin, user: admin, organization: organization }
  let!(:user_role) { create :role, :user, user: user, organization: organization }

  subject { RolePolicy }

  permissions :create? do
    it_behaves_like 'proper permitting'
  end

  permissions :show? do
    it { expect(subject).to permit(owner, user_role) }
    it { expect(subject).to permit(admin, admin_role) }
    it { expect(subject).not_to permit(user, user_role) }
  end

  permissions :update? do
    it_behaves_like 'proper permitting'
  end

  permissions :destroy? do
    it_behaves_like 'proper permitting'
  end
end
