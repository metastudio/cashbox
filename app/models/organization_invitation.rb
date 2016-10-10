# == Schema Information
#
# Table name: invitations
#
#  id            :integer          not null, primary key
#  token         :string(255)      not null
#  email         :string(255)      not null
#  role          :string
#  accepted      :boolean          default(FALSE)
#  invited_by_id :integer
#  created_at    :datetime
#  updated_at    :datetime
#  type          :string
#

class OrganizationInvitation < InvitationBase
  belongs_to :invited_by, inverse_of: :created_invitations, class_name: 'Member'
  belongs_to :organization, inverse_of: :invitations

  validates :invited_by, :role, presence: true
  validates :role, inclusion: { in: %w(user admin owner),
    message: "Should be in user, admin, owner"}
  validate :email_uniq_in_organization

  delegate :organization, to: :invited_by

  after_create :send_invitation

  enumerize :role, in: [:user, :admin, :owner], default: :user, predicates: true

  def owner_name
    invited_by.user.to_s
  end

  def accept!(user)
    Member.find_or_initialize_by(user: user, organization_id: invited_by.organization_id).tap do |member|
      member.role = role
      member.save
    end
    update_attribute(:accepted, true)
  end

  def send_invitation
    date = DateTime.now.beginning_of_day
    kind = :send_invitation_to_organization
    notification(kind, date)
  end

  def resend
    InvitationMailer.resend_invitation_to_organization(self).deliver_now
  end

  private

  def email_uniq_in_organization
    unless organization.invitations.where(email: email).empty?
      errors.add(:email, "An invitation has already been sent")
    end
  end
end
