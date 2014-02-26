class UserOrganization < ActiveRecord::Base
  belongs_to :user
  belongs_to :organization

  validates :user, presence: true
  validates :organization, presence: true
  validates :organization_id, uniqueness: { scope: :user_id }
end
