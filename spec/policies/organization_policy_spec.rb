require 'spec_helper'

describe OrganizationPolicy do

  include_context 'organization with roles'

  subject { OrganizationPolicy }

  permissions :show? do
    it { expect(subject).to permit(owner, organization) }
    it { expect(subject).to permit(admin, organization) }
    it { expect(subject).to permit(user, organization) }
  end

  permissions :update? do
    it_behaves_like "permit owner and admin but user"
  end

  permissions :destroy? do
    it_behaves_like "permit owner and admin but user"
  end

  permissions :edit? do
    it_behaves_like "permit owner and admin but user"
  end
end
