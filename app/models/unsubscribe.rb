class Unsubscribe < ApplicationRecord
  has_secure_token :token

  belongs_to :user, inverse_of: :unsubscribe

  validates :email, presence: true
  validates :email, uniqueness: true

  scope :active, -> { where(active: true) }

  def activate
    update_attributes(active: true)
  end
end
