require 'spec_helper'

describe UserOrganizationPolicy do
  include_context 'organization with roles'

  subject { UserOrganizationPolicy }

  permissions :update? do
    it { expect(subject).to permit(owner_organization, owner_organization) }
    it { expect(subject).to permit(owner_organization, admin_organization) }
    it { expect(subject).to permit(owner_organization, user_organization) }

    it { expect(subject).not_to permit(admin_organization, owner_organization) }
    it { expect(subject).to permit(admin_organization, admin_organization) }
    it { expect(subject).to permit(admin_organization, user_organization) }

    it { expect(subject).not_to permit(user_organization, owner_organization) }
    it { expect(subject).not_to permit(user_organization, admin_organization) }
    it { expect(subject).not_to permit(user_organization, user_organization) }
  end

end
