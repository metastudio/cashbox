class InvitationMailer < ActionMailer::Base
  def new_invitation_to_organization(invitation)
    @invitation = invitation
    @member = invitation.member
    @organization = @member.organization

    mail(to: @invitation.email, subject: 'Invitation to organization')
  end

  def new_invitation_global(invitation)
    @invitation = invitation
    mail(to: @invitation.email, subject: 'Invitation to CASHBOX')
  end
end
