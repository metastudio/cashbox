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
    msg = { notice: "You joined to #{@invitation.member.organization.name}." }
    if current_user.try(:email) == @invitation.email
      @invitation.accept!(current_user)
      redirect_to root_path, msg
    elsif found_by_email = User.find_by(email: @invitation.email)
      @invitation.accept!(found_by_email)
      sign_in found_by_email
      redirect_to root_path, msg
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
