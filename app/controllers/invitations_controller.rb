class InvitationsController < ApplicationController
  skip_filter :authenticate_user!, only: :accept
  before_filter :find_invitation, only: :accept

  def new
    @invitation = Invitation.new
    authorize @invitation, :create?
  end

  def create
    @invitation = current_member.invitations.build(invitation_params)
    authorize @invitation

    if @invitation.save
      redirect_to new_invitation_path, notice: 'An invitation was created successfully'
    else
      render :new
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

  def find_invitation
    @invitation = Invitation.active.find_by(token: params[:token])
    redirect_to root_path, alert: 'Bad invitation token' unless @invitation
  end

  def invitation_params
    params.require(:invitation).permit(:email, :role)
  end

  def user_params
    params.require(:user).permit(:full_name, :password)
  end

end
