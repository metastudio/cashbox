class InvitationsController < ApplicationController
  layout 'settings'
  skip_filter :authenticate_user!, only: :accept
  before_action :find_active_invitation, only: :accept
  before_action :find_invitation, only: [:resend]

  def new
    authorize :invitation
    @invitation = Invitation.new
  end

  def index
    authorize :invitation
    @invitations = current_organization.invitations.page(params[:page]).per(1)
  end

  def create
    @invitation = current_member.created_invitations.build(invitation_params)
    authorize @invitation

    if @invitation.save
      redirect_to new_invitation_path, notice: 'An invitation was created successfully'
    else
      render :new
    end
  end

  def resend
    authorize @invitation
    if @invitation.send_invitation
      redirect_to invitations_path, notice: 'An invitation has been resent'
    else
      redirect_to invitations_path, error: 'Couldn\'t resend an invitation'
    end
  end

  def destroy
    @invitation = Invitation.find(params[:id])
    authorize @invitation
    if @invitation.destroy
      redirect_to invitations_path, notice: 'An inventation was destroyed successfully'
    else
      redirect_to invitations_path, error: 'Couldn\'t destroy an invitation'
    end
  end

  def accept
    if @user = User.find_by(email: @invitation.email)
      if current_user == @user
        @invitation.accept!(@user)
        redirect_to root_path, notice: "You joined #{@invitation.member.organization.name}."
      else
        session['user_return_to'] = accept_invitation_path(token: @invitation.token)
        redirect_to new_user_session_path
      end
    else
      @user = User.new
    end
  end

  private

  def find_active_invitation
    @invitation = Invitation.active.find_by(token: params[:token])
    redirect_to root_path, alert: 'Bad invitation token' unless @invitation
  end

  def find_invitation
    @invitation = Invitation.find_by!(token: params[:token])
  end

  def invitation_params
    params.require(:invitation).permit(:email, :role)
  end

  def user_params
    params.require(:user).permit(:full_name, :password)
  end
end
