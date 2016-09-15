class NotificationJob < ApplicationJob
  queue_as :default

  def perform(organization, title, message)
    ActionCable.server.broadcast(organization, title: title, body: message)
  end
end
