shared_examples_for 'owner or admin with acces to user and admin roles' do
  it { expect(subject).to_not permit(user_member, invitation) }
  it { expect(subject).to_not permit(user_member, invitation_owner) }
  it { expect(subject).to permit(admin_member, invitation) }
  it { expect(subject).to_not permit(admin_member, invitation_owner) }
  it { expect(subject).to permit(owner_member, invitation) }
  it { expect(subject).to permit(owner_member, invitation_owner) }
end
