require 'spec_helper'

describe Profile do
  context "association" do
    it { should belong_to(:user) }
  end

  context "validation" do
    it { should validate_presence_of(:user) }
    it { should validate_uniqueness_of(:user_id) }
    it { should validate_presence_of(:full_name) }
  end
end
