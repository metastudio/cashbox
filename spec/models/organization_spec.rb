require 'spec_helper'

describe Organization do
  context "assocation" do
    it { should belong_to(:owner).class_name('User') }
  end

  context "validation" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:owner) }
  end
end
