module Api::V1
  class OrganizationInvitationsController < ApiController
    before_action :set_invitation, only: [:show, :destroy, :resend]

    api :GET, '/organizations/:organization_id/organization_invitations', 'Return organization invitations'
    def index
      @organization_invitations = current_organization
        .invitations
        .ordered
        .page(params[:page])
        .per(10)
    end

    api :GET, '/organizations/:organization_id/organization_invitations/:id', 'Return organzation invitation'
    def show
    end

    api :POST, '/organizations/:organization_id/organization_invitations', 'Create invitation'
    param :organization_invitation, Hash, required: true, action_aware: true do
      param :email, String, 'Member email', required: true
      param :role, String, 'Member role', required: true
    end
    def create
      @organization_invitation = current_member.created_invitations.build(organization_invitation_params)
      authorize @organization_invitation
      if @organization_invitation.save
        render :show
      else
        render json: @organization_invitation.errors, status: :unprocessable_entity
      end
    end

    api :DELETE, '/organizations/:organization_id/organization_invitations/:id', 'Delete organzation invitation'
    def destroy
      authorize @organization_invitation
      @organization_invitation.destroy
    end

    api :POST, '/organizations/:organization_id/organization_invitations/:id/resend', 'Resend invitation email for invitation organization'
    def resend
      authorize @organization_invitation
      @organization_invitation.send_invitation
    end

    private

    def set_invitation
      @organization_invitation = current_organization.invitations.find(params[:id])
    end

    def organization_invitation_params
      params.require(:organization_invitation).permit(:email, :role)
    end

    def pundit_user
      current_member
    end
  end
end
