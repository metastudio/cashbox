require 'spec_helper'

describe User do
  context "association" do
    it { should have_one(:profile).dependent(:destroy) }
    it { should have_many(:own_organizations).class_name('Organization').dependent(:restrict_with_error) }
    it { should have_many(:members).dependent(:destroy) }
    it { should have_many(:organizations).through(:members) }
  end

  context "validations" do
    subject { create :user }

    it { should validate_presence_of(:email) }
    it { should validate_uniqueness_of(:email).case_insensitive }
    it { should_not allow_value("bad email").for(:email) }
    it { should allow_value("email@test.com").for(:email) }
  end

  context "callback" do
    describe "#build_profile" do
      let(:user) { build :user, profile: nil }
      it "creates profile" do
        expect {
          user.save
        }.to change(user, :profile).from(nil)
      end

      it "creates profile" do
        user.save
        expect(user.profile).to be_persisted
      end
    end
  end
end
