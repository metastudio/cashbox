class InvitationMailer < ActionMailer::Base
  def new_invitation(invitation)
    @invitation = invitation
    @member = invitation.member
    @organization = @member.organization

    mail(to: @invitation.email, subject: 'Invitation')
  end
end
