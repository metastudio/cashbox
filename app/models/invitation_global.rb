class InvitationGlobal < Invitation
  has_many :notifications, as: :notificator

  validate :user_already_in_system

  after_create :send_invitation
  after_create :resend_notification

  def send_invitation
    date = DateTime.now.beginning_of_day
    kind = :send_invitation_global
    notification(kind, date)
  end

  def resend_notification
    date = 1.week.from_now.beginning_of_day
    kind = :resend_invitation_global
    notification(kind, date)
  end

  def congratulation
    "You joined CASHBOX."
  end

  def accept!(user)
    update_attribute(:accepted, true)
  end


  private

  def user_already_in_system
    user = User.where(email: email)
    if user.present?
      errors.add(:email, "User already registered in system")
    end
  end
end
