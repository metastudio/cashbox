# == Schema Information
#
# Table name: members
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  organization_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#  role            :string(255)      not null
#

require 'spec_helper'

describe Member do
  context "association" do
    it { should belong_to(:user) }
    it { should belong_to(:organization) }
  end

  context "validation" do
    subject { create :member }
    it { should validate_presence_of(:user) }
    it { should validate_presence_of(:organization) }
    it { should validate_uniqueness_of(:organization_id).scoped_to(:user_id)}
  end
end
