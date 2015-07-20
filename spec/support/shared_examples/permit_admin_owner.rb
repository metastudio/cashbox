shared_examples_for "permit owner and admin but user" do
  it { expect(subject).to permit(owner_member, organization) }
  it { expect(subject).to permit(admin_member, organization) }
  it { expect(subject).not_to permit(user_member, organization) }
end
