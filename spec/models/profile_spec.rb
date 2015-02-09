# == Schema Information
#
# Table name: profiles
#
#  id           :integer          not null, primary key
#  user_id      :integer          not null
#  position     :string
#  avatar       :string
#  phone_number :string
#  created_at   :datetime
#  updated_at   :datetime
#

require 'spec_helper'

describe Profile do
  context "association" do
    it { should belong_to(:user) }
  end

  context "validation" do
    it { should validate_presence_of(:user) }
    it { should validate_uniqueness_of(:user_id) }
  end
end
