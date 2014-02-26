# == Schema Information
#
# Table name: profiles
#
#  id           :integer          not null, primary key
#  user_id      :integer          not null
#  full_name    :string(255)
#  position     :string(255)
#  avatar       :string(255)
#  phone_number :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Profile < ActiveRecord::Base
  belongs_to :user, inverse_of: :profile

  validates :user, presence: true
  validates :user_id, uniqueness: true
  validates :full_name, presence: true
end
