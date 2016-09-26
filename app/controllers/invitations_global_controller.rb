class InvitationsGlobalController < ApplicationController
  layout 'settings', except: :accept
  skip_before_action :authenticate_user!, only: :accept
  before_action :find_active_invitation, only: :accept

  def new
    @invitation = InvitationGlobal.new
  end

  def create
    @invitation = InvitationGlobal.new(invitation_params)

    if @invitation.save
      redirect_to new_invitations_global_path, notice: 'An invitation was created successfully'
    else
      render :new
    end
  end

  def accept
    if @user = User.find_by(email: @invitation.email)
      if user_signed_in? && current_user.id == @user.id
        @invitation.accept!(@user)
        redirect_to root_path, notice: @invitation.congratulation
      else
        session['user_return_to'] = accept_invitation_path(token: @invitation.token)
        sign_out current_user if user_signed_in?
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

  def invitation_params
    params.require(:invitation_global).permit(:email, :role)
  end
end
