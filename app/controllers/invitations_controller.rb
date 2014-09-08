class InvitationsController < ApplicationController
  skip_filter :authenticate_user!, only: [:accept, :create_user]
  before_filter :find_invitation, only: [:accept, :create_user]
  before_filter :find_user, only: [:accept]

  def new
    @invitation = Invitation.new
  end

  def create
    @invitation = Invitation.new(invitation_params)
    @invitation.member = current_member
    @invitation.token = invitation_token

    authorize @invitation

    if @invitation.save
      redirect_to new_invitation_path, notice: 'An invitation was created successfully'
    else
      flash.now[:alert] = 'An error occured'
      render :new
    end

  end

  def accept
    if @user.present?
      Member.create(user: @user, organization_id: @invitation.member.organization_id, role: @invitation.role)
      @invitation.destroy
      sign_in @user
      redirect_to root_path, notice: "You joined to #{@invitation.member.organization.name}"
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
      render :accept
    end
  end

  private

  def invitation_token
    @invitation_token ||= SecureRandom.hex(10)
  end

  def find_invitation
    @invitation = Invitation.find_by(token: params[:token])
    redirect_to root_path, alert: 'Bad invitation token' unless @invitation
  end

  def invitation_params
    params.require(:invitation).permit(:email, :role)
  end

  def user_params
    params.require(:user).permit(:full_name, :password)
  end

  def find_user
    @user = User.find_by(email: @invitation.email)
  end
end
