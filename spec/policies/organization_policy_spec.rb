require 'spec_helper'

describe OrganizationPolicy do

  let(:owner) { create :user }
  let(:admin) { create :user }
  let(:user) { create :user }
  let(:ordinary_user) { create :user }
  let(:organization) { create :organization }
  let!(:owner_role) { create :role, :owner, user: owner, organization: organization }
  let!(:admin_role) { create :role, :admin, user: admin, organization: organization }
  let!(:user_role) { create :role, :user, user: user, organization: organization }

  subject { OrganizationPolicy }



  permissions :create? do
    it { expect(subject).to permit(ordinary_user, Organization.new) }
  end

  permissions :show? do
    it { expect(subject).to permit(owner, organization) }
    it { expect(subject).to permit(admin, organization) }
    it { expect(subject).to permit(user, organization) }
  end

  permissions :update? do
    it { expect(subject).to permit(owner, organization) }
    it { expect(subject).to permit(admin, organization) }
  end

  permissions :destroy? do
    it { expect(owner_policy).to permit(:destroy) }
  end

end
