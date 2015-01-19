class InvitationsController < ApplicationController
  skip_filter :authenticate_user!, only: [:accept, :create_user]
  before_filter :find_invitation, only: [:accept, :create_user]

  def new
    @invitation = Invitation.new
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
    if current_user
      if current_user.email == @invitation.email
        @invitation.accept!(current_user)
        redirect_to root_path, notice:
          "You joined to #{@invitation.member.organization.name}."
      else
        @user = User.new
      end
    elsif found_by_email = User.find_by(email: @invitation.email)
      @invitation.accept!(found_by_email)
      redirect_to new_user_session_path, notice:
        "You joined to #{@invitation.member.organization.name}.
        Please Log In."
    else
      @user = User.new
    end
  end

  def create_user
    @user = User.new(user_params)
    @user.email = @invitation.email

    if @user.save
      redirect_to accept_invitation_path(token: @invitation.token)
    else
      raise [@user.errors].inspect
      render :accept
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
