require 'spec_helper'

describe Organization do
  context "assocation" do
    it { should belong_to(:owner).class_name('User') }
    it { should have_many(:members).dependent(:destroy) }
    it { should have_many(:bank_accounts).dependent(:destroy) }
    it { should have_many(:users).through(:members) }
    it { should have_many(:categories).dependent(:destroy) }
    it { should have_many(:transactions).through(:bank_accounts) }
  end

  context "validation" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:owner) }
  end

  context "callback" do
    let(:user) { create :user }
    let(:organization) { build :organization, owner: user }

    describe "#add_to_owner" do
      subject{ organization.save }

      it "adds created organization to owner's users orgainzations" do
        expect{ subject }.to change{ user.members.count }.by(1)
      end

      it "sets role owner for the creator" do
        subject
        expect(Member.last.role).to eq 'owner'
      end
    end
  end
end
