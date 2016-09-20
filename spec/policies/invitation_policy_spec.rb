require 'rails_helper'

describe InvitationPolicy do
  include_context 'organization with roles'
  let(:invitation)       { create :invitation, member: owner_member }
  let(:invitation_owner) { create :invitation, member: owner_member, role: 'owner' }

  subject { InvitationPolicy }

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
    let(:invitations) { Invitation.all }
    it { expect(subject).to permit(admin_member, invitations) }
    it { expect(subject).to permit(owner_member, invitations) }
    it { expect(subject).to_not permit(user_member, invitations) }
  end
end
