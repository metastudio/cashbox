require 'spec_helper'

describe OrganizationPolicy do

  include_context 'organization with roles'

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
    it { expect(subject).to permit(owner, organization) }
    it { expect(subject).not_to permit(admin, organization) }
    it { expect(subject).not_to permit(user, organization) }
  end

end
