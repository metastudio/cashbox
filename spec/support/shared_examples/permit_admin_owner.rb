shared_examples_for "permit owner and admin but user" do
  it { expect(subject).to permit(owner, organization) }
  it { expect(subject).to permit(admin, organization) }
  it { expect(subject).not_to permit(user, organization) }
end
