shared_examples_for "organization buttons" do
  context 'admin user' do
    let!(:member) { create :member, :admin, user: user }

    it "is able to edit organization" do
      within '.btn-group' do
        is_expected.to have_content('Edit')
      end
    end

    it "is able to delete organization" do
      within '.btn-group' do
        is_expected.to have_content('Delete')
      end
    end
  end

  context 'owner user' do
    let!(:member) { create :member, :owner, user: user }

    it "is able to edit organization" do
      within '.btn-group' do
        is_expected.to have_content('Edit')
      end
    end

    it "is able to delete organization" do
      is_expected.to have_content('Delete')
    end
  end

  context 'ordinary user' do
    let!(:member) { create :member, :user, user: user }

    it "is NOT able to edit organization" do
      within '.btn-group' do
        is_expected.to_not have_content('Edit')
      end
    end

    it "is NOT able to delete organization" do
      within '.btn-group' do
        is_expected.to_not have_content('Delete')
      end
    end
  end
end
