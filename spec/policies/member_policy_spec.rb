require 'spec_helper'

describe MemberPolicy do
  include_context 'organization with roles'


  let(:owner_context) { UserContext.new(owner_member) }
  let(:admin_context) { UserContext.new(admin_member) }
  let(:admin_wrong_context) { UserContext.new(admin_member, {member: {role: 'owner'}}) }
  let(:user_context) { UserContext.new(user_member) }


  subject { MemberPolicy }

  permissions :update? do
    it { expect(subject).to permit(owner_context, owner_member) }
    it { expect(subject).to permit(owner_context, admin_member) }
    it { expect(subject).to permit(owner_context, user_member) }

    it { expect(subject).not_to permit(admin_context, owner_member) }
    it { expect(subject).to permit(admin_context, admin_member) }
    it { expect(subject).to permit(admin_context, user_member) }
    it { expect(subject).not_to permit(admin_wrong_context, user_member) }

    it { expect(subject).not_to permit(user_context, owner_member) }
    it { expect(subject).not_to permit(user_context, admin_member) }
    it { expect(subject).not_to permit(user_context, user_member) }
  end

end
