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
#  last_visited_at :datetime
#

class Member < ActiveRecord::Base
  extend Enumerize

  belongs_to :user
  belongs_to :organization

  has_many :created_invitations, class_name: 'Invitation',
    foreign_key: :invited_by_id, dependent: :destroy

  validates :user, presence: true
  validates :organization, presence: true
  validates :organization_id, uniqueness: { scope: :user_id }

  enumerize :role, in: [:user, :admin, :owner], default: :user, predicates: true

  delegate :full_name, to: :user, prefix: true

  scope :ordered, -> { order('created_at DESC') }

  def owner_or_admin?
    owner? || admin?
  end

  def available_roles
    if role == 'owner'
      Member.role.options
    else
      Member.role.options(except: 'owner')
    end
  end
end
