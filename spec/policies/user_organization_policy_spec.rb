require 'spec_helper'

describe UserOrganizationPolicy do
  include_context 'organization with roles'


  let(:owner_context) { UserContext.new(owner_organization) }
  let(:admin_context) { UserContext.new(admin_organization) }
  let(:admin_wrong_context) { UserContext.new(admin_organization, {user_organization: {role: 'owner'}}) }
  let(:user_context) { UserContext.new(user_organization) }


  subject { UserOrganizationPolicy }

  permissions :update? do
    it { expect(subject).to permit(owner_context, owner_organization) }
    it { expect(subject).to permit(owner_context, admin_organization) }
    it { expect(subject).to permit(owner_context, user_organization) }

    it { expect(subject).not_to permit(admin_context, owner_organization) }
    it { expect(subject).to permit(admin_context, admin_organization) }
    it { expect(subject).to permit(admin_context, user_organization) }
    it { expect(subject).not_to permit(admin_wrong_context, user_organization) }

    it { expect(subject).not_to permit(user_context, owner_organization) }
    it { expect(subject).not_to permit(user_context, admin_organization) }
    it { expect(subject).not_to permit(user_context, user_organization) }
  end

end
