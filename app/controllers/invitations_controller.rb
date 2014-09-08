class InvitationsController < ApplicationController

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
  end

  private

  def invitation_token
    @invitation_token ||= SecureRandom.hex(10)
  end

  def invitation_params
    params.require(:invitation).permit(:email, :role)
  end
end
