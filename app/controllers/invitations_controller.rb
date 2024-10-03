class InvitationsController < ApplicationController
  layout 'settings', except: :accept
  skip_before_action :authenticate_user!, only: :accept
  before_action :find_active_invitation, only: :accept

  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = Invitation.new(invitation_params)
    @invitation.invited_by = current_user

    if @invitation.save
      redirect_to new_invitation_path, notice: 'An invitation was created successfully'
    else
      render :new
    end
  end

  def accept
    if @user = User.find_by(email: @invitation.email)
      # Invitation to Organization allowed only for existing Users
      if user_signed_in? && current_user.id == @user.id
        @invitation.accept!(@user)
        redirect_to root_path, notice: invitation_congratulation(@invitation)
      else
        # If User not Signed In at the moment of accepting invite - he will be redirected to SignIn page
        session['user_return_to'] = accept_invitation_path(token: @invitation.token)
        sign_out current_user if user_signed_in?
        redirect_to new_user_session_path
      end
    else
      # Invitation to the system (without Organization) allow to create a new User
      @user = User.new
    end
  end

  private

  def find_active_invitation
    @invitation = InvitationBase.active.find_by(token: params[:token])
    redirect_to root_path, alert: 'Bad invitation token' unless @invitation
  end

  def invitation_params
    params.require(:invitation).permit(:email, :role)
  end
end
