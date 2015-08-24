class MembersController < ApplicationController
  layout 'settings'
  before_filter :find_member, only: [:edit, :update]

  def index
    @members = current_organization.members.includes(:user)
    @invitations = current_organization.invitations.page(params[:page]).per(10)
  end

  def edit
  end

  def update
    @member.update_attributes(member_params)
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
