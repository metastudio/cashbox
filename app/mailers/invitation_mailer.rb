class InvitationMailer < ActionMailer::Base
  layout 'unsubscribe'

  def new_invitation_to_organization(invitation)
    invitation_to_organization(invitation)
  end

  def new_invitation(invitation)
    invitaton_global(invitation)
  end

  def resend_invitation(invitation)
    invitaton_global(invitation)
  end

  def resend_invitation_to_organization(invitation)
    invitation_to_organization(invitation)
  end

  private

  def invitaton_global(invitation)
    @invitation = invitation
    @unsubscribe = Unsubscribe.find_or_create_by(email: @invitation.email)
    unless @unsubscribe.active?
      mail(to: @invitation.email, subject: 'Invitation to CASHBOX')
    end
  end

  def invitation_to_organization(invitation)
    @invitation = invitation
    @unsubscribe = Unsubscribe.find_or_create_by(email: @invitation.email)
    unless @unsubscribe.active?
      @member = @invitation.invited_by
      @organization = @member.organization
      mail(to: @invitation.email, subject: 'Invitation to organization')
    end
  end
end
