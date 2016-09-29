class InvitationToOrganization < Invitation
  belongs_to :member, inverse_of: :created_invitations, foreign_key: :invited_by_id
  belongs_to :organization, inverse_of: :invitations
  has_many :notifications, as: :notificator

  validates :invited_by_id, :role, presence: true
  validate :role_inclusion
  validate :email_uniq

  delegate :organization, to: :member

  after_create :send_invitation
  after_create :resend_invitation

  enumerize :role, in: [:user, :admin, :owner], default: :user, predicates: true

  def owner
    Member.find(self.invited_by_id).user.to_s
  rescue
    ''
  end

  def accept!(user)
    user_member = Member.find_or_create_by!(user: user, organization_id: member.organization_id)
    user_member.update_attribute(:role, role)
    update_attribute(:accepted, true)
  end

  def congratulation
    "You joined #{member.organization.name}."
  end

  def send_invitation
    date = DateTime.now.beginning_of_day
    kind = :send_invitation_to_organization
    notification(kind, date)
  end

  def resend_invitation
    date = 1.week.from_now.beginning_of_day
    kind = :resend_invitation_to_organization
    notification(kind, date)
  end

  private

  def role_inclusion
    if invited_by_id
      unless member.available_roles.to_h.values.include?(role)
        errors.add(:role, "Should be in #{member.available_roles.to_h.keys.join(', ')}")
      end
    end
  end

  def email_uniq
    unless organization.invitations.where(email: email).empty?
      errors.add(:email, "An invitation has already been sent")
    end
  end
end
