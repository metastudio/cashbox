# == Schema Information
#
# Table name: members
#
#  id              :integer          not null, primary key
#  user_id         :integer          not null
#  organization_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#  role            :string(255)      not null
#

class Member < ActiveRecord::Base
  extend Enumerize

  belongs_to :user
  belongs_to :organization

  validates :user, presence: true
  validates :organization, presence: true
  validates :organization_id, uniqueness: { scope: :user_id }

  enumerize :role, in: [:user, :admin, :owner], default: :user, predicates: true

  delegate :full_name, to: :user, prefix: true

  def owner_or_admin?
    owner? || admin?
  end

  def self.available_roles_for(role)
    unless role == 'owner'
      Member.role.options(except: 'owner')
    else
      Member.role.options
    end
  end
end
