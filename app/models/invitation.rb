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

class Invitation < InvitationBase
  belongs_to :invited_by, inverse_of: :created_invitations, class_name: 'User'

  validates :invited_by, presence: true
  validate :user_already_in_system

  after_create :send_invitation

  def send_invitation
    InvitationMailer.new_invitation_global(self).deliver_now
  end

  def accept!(user)
    update_attribute(:accepted, true)
  end

  def resend
    InvitationMailer.resend_invitation_global(self).deliver_now
  end

  def resend_notification
    date = 1.week.from_now.beginning_of_day
    kind = :resend_invitation
    notification(kind, date)
  end
  private

  def user_already_in_system
    user = User.where(email: email)
    if user.present?
      errors.add(:email, "User already registered in system")
    end
  end
end
