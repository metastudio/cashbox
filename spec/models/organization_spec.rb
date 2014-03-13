require 'spec_helper'

describe Organization do
  context "assocation" do
    it { should belong_to(:owner).class_name('User') }
    it { should have_many(:user_organizations).dependent(:destroy) }
    it { should have_many(:bank_accounts).dependent(:destroy) }
    it { should have_many(:users).through(:user_organizations) }
    it { should have_many(:categories).dependent(:destroy) }
    it { should have_many(:transactions).through(:bank_accounts) }
  end

  context "validation" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:owner) }
  end

  context "callback" do
    describe "#add_to_owner" do
      let(:user) { create :user }
      let(:organization) { build :organization, owner: user }

      subject{ organization.save }

      it "adds created organization to owner's users orgainzations" do
        expect{ subject }.to change{ user.user_organizations.count }.by(1)
      end
    end
  end
end
