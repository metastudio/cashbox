class MembersController < ApplicationController
  layout 'settings'
  before_action :find_member, only: [:edit, :update, :destroy]

  def index
    @members = current_organization.members.ordered.includes(:user).page(params[:member_page]).per(10)
    @invitations = current_organization.invitations.ordered.page(params[:invitation_page]).per(10)
  end

  def edit
  end

  def update
    @member.update_attributes(member_params)
  end

  def destroy
    @member.destroy
    redirect_to members_path, notice: 'Member was successfully removed from organization.'
  end

  private

  def find_member
    @member = current_organization.members.find(params[:id])
    authorize @member
  end

  def member_params
    params.require(:member).permit(:role)
  end

  def pundit_user
    MemberContext.new(super, params)
  end
end
