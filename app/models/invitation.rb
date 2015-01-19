class Invitation < ActiveRecord::Base
  extend Enumerize

  has_secure_token :token

  belongs_to :member, inverse_of: :invitations, foreign_key: :invited_by_id
  belongs_to :organization, inverse_of: :invitations

  after_create :send_invitation

  validates :invited_by_id, presence: true
  validates :role, presence: true
  validates :email, presence: true, format: { with: Devise.email_regexp }
  validate :email_uniq

  enumerize :role, in: [:user, :admin, :owner], default: :user, predicates: true

  delegate :organization, to: :member

  scope :active, -> { where(accepted: false) }

  def accept!(user)
    Member.create(user: user, organization_id: member.organization_id, role: role)
    update_attribute(:accepted, true)
  end

  private

  def send_invitation
    InvitationMailer.new_invitation(self).deliver
  end

  def email_uniq
    unless organization.invitations.active.where(email: email).empty?
      errors.add(:email, "An invitation has already been sent")
    end
  end
end
