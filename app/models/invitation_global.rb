class InvitationGlobal < Invitation
  validate :user_already_in_system

  after_create :send_invitation

  def send_invitation
    InvitationMailer.new_invitation_global(self).deliver_now
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
