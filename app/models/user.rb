# frozen_string_literal: true

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
#  subscribed             :boolean          default(TRUE)
#

class User < ApplicationRecord
  class AuthenticationRequiredError < StandardError
    def initialize(msg = 'Authentication required.')
      super(msg)
    end
  end

  has_one :profile, inverse_of: :user, dependent: :destroy
  has_many :own_organizations, -> { where members: { role: 'owner' } },
    through: :members, source: :organization, dependent: :restrict_with_error, inverse_of: :owners
  has_many :members, inverse_of: :user, dependent: :destroy
  has_many :organizations, through: :members
  has_many :invitations, foreign_key: :email, primary_key: :email,
    inverse_of: :user, class_name: 'InvitationBase', dependent: :destroy
  has_many :transactions, inverse_of: :created_by, foreign_key: :created_by_id, dependent: :nullify
  has_one  :unsubscribe, inverse_of: :user, dependent: :destroy
  has_many :created_invitations, inverse_of: :invited_by, class_name: 'Invitation',
    foreign_key: :invited_by_id, dependent: :destroy

  accepts_nested_attributes_for :profile, update_only: true
  accepts_nested_attributes_for :unsubscribe, update_only: true

  devise :database_authenticatable, :recoverable, :rememberable, :trackable, :validatable, :lockable

  validates :full_name, presence: true
  validates :password, :password_confirmation, length: { maximum: 30 }

  before_create :build_profile, if: ->{ profile.blank? }
  after_create :link_unsubscribe

  delegate :avatar, to: :profile

  scope :without, ->(user) { where.not(id: user.id) }

  def to_s
    full_name.truncate(30)
  end

  def authenticate(password)
    valid_password?(password)
  end

  def locked?
    locked_at.present?
  end

  def link_unsubscribe
    unsubscribe = Unsubscribe.find_or_create_by(email: email)
    update(unsubscribe: unsubscribe)
  end
end
