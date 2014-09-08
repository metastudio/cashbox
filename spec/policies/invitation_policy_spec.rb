require 'spec_helper'

describe InvitationPolicy do
  include_context 'organization with roles'

  subject { InvitationPolicy }

  permissions :create? do
    it { expect(subject).to permit(admin_member, Invitation.new) }
    it { expect(subject).not_to permit(admin_member, Invitation.new(role: 'owner')) }
    it { expect(subject).not_to permit(user_member, Invitation.new) }
    it { expect(subject).to permit(owner_member, Invitation.new(role: 'owner')) }
  end
end
