require 'spec_helper'

describe OrganizationPolicy do

  include_context 'organization with roles'

  subject { OrganizationPolicy }

  permissions :show? do
    it { expect(subject).to permit(owner_member, organization) }
    it { expect(subject).to permit(admin_member, organization) }
    it { expect(subject).to permit(user_member, organization) }
  end

  permissions :update? do
    it { expect(subject).to permit(owner_member, organization) }
    it { expect(subject).to permit(admin_member, organization) }
  end

  permissions :destroy? do
    it { expect(subject).to permit(owner_member, organization) }
    it { expect(subject).not_to permit(admin_member, organization) }
    it { expect(subject).not_to permit(user_member, organization) }
  end

end
