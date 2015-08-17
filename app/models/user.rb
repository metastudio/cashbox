# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string
#  last_sign_in_ip        :string
#  failed_attempts        :integer          default(0), not null
#  unlock_token           :string
#  locked_at              :datetime
#  created_at             :datetime
#  updated_at             :datetime
#  full_name              :string           not null
#

class User < ActiveRecord::Base
  has_one :profile, inverse_of: :user, dependent: :destroy
  has_many :own_organizations,
    -> { where members: { role: "owner" } },
    through: :members, source: :organization, dependent: :restrict_with_error, inverse_of: :owners
  has_many :members, inverse_of: :user, dependent: :destroy
  has_many :organizations, through: :members
  has_many :invitations, foreign_key: :email, primary_key: :email, inverse_of: :user

  accepts_nested_attributes_for :profile, update_only: true

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :lockable

  validates :full_name, presence: true

  before_create :build_profile, if: ->{ profile.blank? }

  delegate :avatar, to: :profile

  scope :without, ->(user) { where("id <> ?", user.id) }

  def to_s
    full_name.truncate(30)
  end
end
