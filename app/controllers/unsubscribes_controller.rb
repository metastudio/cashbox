class UnsubscribesController < ApplicationController
  skip_before_action :authenticate_user!

  def activate
    @unsubscribe = Unsubscribe.where(token: params[:token]).first
    if @unsubscribe.present?
      @unsubscribe.activate
    else
      flash[:alert] = "Invalid token"
      redirect_to new_user_session_path
    end
  end
end
