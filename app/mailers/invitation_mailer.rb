class InvitationMailer < ActionMailer::Base
  def new_invitation(invitation)
    @invitation = invitation
    @user = invitation.user
    @organization = invitation.organization

    mail(to: @user.email, subject: 'Invitation', from: '<no-reply@cashbox.dev>')
  end
end
