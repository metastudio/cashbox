class Invitation < ActiveRecord::Base
  extend Enumerize

  has_secure_token :token

  belongs_to :member, inverse_of: :created_invitations, foreign_key: :invited_by_id
  belongs_to :organization, inverse_of: :invitations
  belongs_to :user, primary_key: :email, foreign_key: :email, inverse_of: :invitations

  after_create :send_invitation

  validates :invited_by_id, presence: true
  validates :role, presence: true
  validate :role_inclusion
  validates :email, presence: true, format: { with: Devise.email_regexp }
  validate :email_uniq

  enumerize :role, in: [:user, :admin, :owner], default: :user, predicates: true

  delegate :organization, to: :member

  scope :active, -> { where(accepted: false) }

  def accept!(user)
    user_member = Member.find_or_create_by!(user: user, organization_id: member.organization_id)
    user_member.update_attribute(:role, role)
    update_attribute(:accepted, true)
  end

  private

  def send_invitation
    InvitationMailer.new_invitation(self).deliver_now
  end

  def email_uniq
    unless organization.invitations.active.where(email: email).empty?
      errors.add(:email, "An invitation has already been sent")
    end
  end

  def role_inclusion
    if invited_by_id
      unless member.available_roles.to_h.values.include?(role)
        errors.add(:role, "Should be in #{member.available_roles.to_h.keys.join(', ')}")
      end
    end
  end
end
