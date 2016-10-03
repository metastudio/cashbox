class OrganizationInvitationsController < ApplicationController
  layout 'settings', except: :accept
  before_action :find_invitation, only: [:resend]

  def new
    authorize :organization_invitation
    @invitation = OrganizationInvitation.new
  end

  def create
    @invitation = current_member.created_invitations.build(invitation_params)
    authorize @invitation

    if @invitation.save
      redirect_to new_organization_invitation_path, notice: 'An invitation was created successfully'
    else
      render :new
    end
  end

  def resend
    authorize @invitation
    if @invitation.send_invitation
      redirect_to members_path, notice: 'An invitation has been resent'
    else
      redirect_to members_path, error: 'Couldn\'t resend an invitation'
    end
  end

  def destroy
    @invitation = OrganizationInvitation.find(params[:id])
    authorize @invitation
    if @invitation.destroy
      redirect_to members_path, notice: 'An inventation was destroyed successfully'
    else
      redirect_to members_path, error: 'Couldn\'t destroy an invitation'
    end
  end

  private

  def find_invitation
    @invitation = current_organization.invitations.find_by!(token: params[:token])
  end

  def invitation_params
    params.require(:organization_invitation).permit(:email, :role)
  end
end
