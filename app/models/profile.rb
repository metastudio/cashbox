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

class Profile < ApplicationRecord
  belongs_to :user, inverse_of: :profile

  validates :user, presence: true
  validates :user_id, uniqueness: true
end
