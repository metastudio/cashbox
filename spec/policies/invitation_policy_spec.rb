require 'rails_helper'

describe OrganizationInvitationPolicy do
  include_context 'organization with roles'
  let(:invitation)       { create :organization_invitation, invited_by: owner_member }
  let(:invitation_owner) { create :organization_invitation, invited_by: owner_member, role: 'owner' }

  subject { OrganizationInvitationPolicy }

  permissions :create? do
    it_behaves_like "owner or admin with acces to user and admin roles"
  end
  permissions :destroy? do
    it_behaves_like "owner or admin with acces to user and admin roles"
  end
  permissions :resend? do
    it_behaves_like "owner or admin with acces to user and admin roles"
  end

  permissions :index? do
    let(:invitations) { OrganizationInvitation.all }
    it { expect(subject).to permit(admin_member, invitations) }
    it { expect(subject).to permit(owner_member, invitations) }
    it { expect(subject).to_not permit(user_member, invitations) }
  end
end
