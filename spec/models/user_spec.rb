require 'spec_helper'

describe User do
  context "association" do
    it { should have_one(:profile).dependent(:destroy) }
  end

  context "validations" do
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
