# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  owner_id   :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class Organization < ActiveRecord::Base
  belongs_to :owner, class_name: 'User', inverse_of: :own_organizations
  has_many :user_organizations, inverse_of: :organization, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :users, through: :user_organizations
  has_many :bank_accounts, dependent: :destroy, inverse_of: :organization
  has_many :transactions, through: :bank_accounts, inverse_of: :organization

  validates :name, presence: true
  validates :owner, presence: true

  after_create :add_to_owner

  private

  def add_to_owner
    self.owner.organizations << self
    user_organization = UserOrganization.find_by(user_id: self.owner.id, organization_id: self.id)
    user_organization.role = :owner
    user_organization.save
  end
end
