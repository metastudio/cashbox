class NotificationChannel < ApplicationCable::Channel
  def subscribed
    current_user.organizations.each do |organization|
      stream_from organization.name
    end
  end
end