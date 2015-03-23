shared_examples_for "organization buttons" do
  context 'admin user' do
    let!(:member) { create :member, :admin, user: user }

    it "is able to edit organization" do
      expect(subject).to have_content('Edit')
    end

    it "is able to delete organization" do
      expect(subject).to have_content('Destroy')
    end
  end

  context 'owner user' do
    let!(:member) { create :member, :owner, user: user }

    it "is able to edit organization" do
      expect(subject).to have_content('Edit')
    end

    it "is able to delete organization" do
      expect(subject).to have_content('Destroy')
    end
  end

  context 'ordinary user' do
    let!(:member) { create :member, :user, user: user }

    it "is NOT able to edit organization" do
      expect(subject).to_not have_content('Edit')
    end

    it "is NOT able to delete organization" do
      expect(subject).to_not have_content('Destroy')
    end
  end
end
