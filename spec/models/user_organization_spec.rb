require 'spec_helper'

describe UserOrganization do
  context "association" do
    it { should belong_to(:user) }
    it { should belong_to(:organization) }
  end

  context "validation" do
    subject { create :user_organization }
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:organization) }
    it { should validate_uniqueness_of(:organization_id).scoped_to(:user_id)}
  end
end
