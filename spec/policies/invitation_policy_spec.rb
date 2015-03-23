require 'spec_helper'

describe InvitationPolicy do
  include_context 'organization with roles'

  subject { InvitationPolicy }

  permissions :owner_or_admin_for_record? do
    let(:invitation)       { create :invitation, member: owner_member }
    let(:invitation_owner) { create :invitation, member: owner_member, role: 'owner' }

    def owner_or_admin_for_record
      it { expect(subject).to_not permit(user_member, invitation) }
      it { expect(subject).to_not permit(user_member, invitation_owner) }
      it { expect(subject).to permit(admin_member, invitation) }
      it { expect(subject).to_not permit(admin_member, invitation_owner) }
      it { expect(subject).to permit(owner_member, invitation) }
      it { expect(subject).to permit(owner_member, invitation_owner) }
    end

    context 'create' do
      owner_or_admin_for_record
    end

    context 'destroy' do
      owner_or_admin_for_record
    end

    context 'resend' do
      owner_or_admin_for_record
    end

    context 'index' do
      let(:invitations) { Invitation.all }
      it { expect(subject).to permit(admin_member, invitations) }
      it { expect(subject).to permit(owner_member, invitations) }
      it { expect(subject).to_not permit(user_member, invitations) }
    end
  end
end
