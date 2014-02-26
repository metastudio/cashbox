require 'spec_helper'

describe Organization do
  context "assocation" do
    it { should belong_to(:owner).class_name('User') }
    it { should have_many(:user_organizations).dependent(:destroy) }
    it { should have_many(:users).through(:user_organizations) }
  end

  context "validation" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:owner) }
  end
end
