# == Schema Information
#
# Table name: invitations
#
#  id            :integer          not null, primary key
#  token         :string(255)      not null
#  email         :string(255)      not null
#  role          :string(255)      not null
#  invited_by_id :integer          not null
#  accepted      :boolean          default(FALSE)
#  created_at    :datetime
#  updated_at    :datetime
#

class Invitation < ApplicationRecord
  extend Enumerize

  has_secure_token :token

  belongs_to :user, primary_key: :email, foreign_key: :email, inverse_of: :invitations

  validates :email, presence: true
  validates :email, format: { with: Devise.email_regexp, message: "invalid format" }
  validates :email, length: { maximum: 255, message: "too long" }

  scope :ordered, -> { order('created_at DESC') }
  scope :active,  -> { where(accepted: false) }
end
