class InvitationsController < ApplicationController
  before_filter :find_user, only: [:create]

  def new
    @invitation = Invitation.new
  end

  def create
    @user ||= User.create(email: params[:email], full_name: 'Please change', password: invitation_token)

    if Invitation.create(user: @user, organization: current_organization, token: invitation_token).valid?
      redirect_to new_invitation_path, notice: 'Invitation was created successfully'
    else
      flash.now[:alert] = 'An error occured'
      render :new
    end

  end

  def accept
  end

  private

  def find_user
    @user = User.find_by(email: params[:email])
  end

  def invitation_token
    @invitation_token ||= SecureRandom.hex(10)
  end
end
