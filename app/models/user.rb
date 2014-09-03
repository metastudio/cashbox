# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string(255)
#  locked_at              :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  full_name              :string(255)      not null
#

class User < ActiveRecord::Base
  has_one :profile, inverse_of: :user, dependent: :destroy
  has_many :own_organizations, class_name: 'Organization', foreign_key: :owner_id, inverse_of: :owner, dependent: :restrict_with_error
  has_many :user_organizations, inverse_of: :user, dependent: :destroy
  has_many :organizations, through: :user_organizations


  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :lockable

  validates :full_name, presence: true

  before_create :build_profile, if: ->{ profile.blank? }

  delegate :avatar, to: :profile

  scope :without, ->(user) { where("id <> ?", user.id) }

  def to_s
    full_name
  end

  def role_in(organization)
    user_organizations.find_by(organization_id: organization.id).role
  end

  def admin_in?(organization)
    role_in(organization) == 'admin'
  end

  def owner_in?(organization)
    role_in(organization) == 'owner'
  end

  def owner_or_admin_in?(organization)
    owner_in?(organization) || admin_in?(organization)
  end


end
