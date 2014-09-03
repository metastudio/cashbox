# == Schema Information
#
# Table name: user_organizations
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  organization_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#

class UserOrganization < ActiveRecord::Base
  extend Enumerize

  belongs_to :user
  belongs_to :organization

  validates :user, presence: true
  validates :organization, presence: true
  validates :organization_id, uniqueness: { scope: :user_id }

  enumerize :role, in: [:user, :admin, :owner], default: :user, predicates: true

  delegate :full_name, to: :user, prefix: true

  def admin?
    role == 'admin'
  end

  def owner?
    role == 'owner'
  end

  def owner_or_admin?
    owner? || admin?
  end
end
