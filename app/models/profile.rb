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

class Profile < ActiveRecord::Base
  belongs_to :user, inverse_of: :profile

  validates :user, presence: true
  validates :user_id, uniqueness: true
end
