# == Schema Information
#
# Table name: profiles
#
#  id           :integer          not null, primary key
#  user_id      :integer          not null
#  position     :string(255)
#  avatar       :string(255)
#  phone_number :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

require 'rails_helper'

describe Profile do
  subject { build(:profile)}
  context 'association' do
    it { should belong_to(:user) }
  end

  context 'validation' do
    it { should validate_presence_of(:user) }
    it { should validate_uniqueness_of(:user_id) }
  end
end
