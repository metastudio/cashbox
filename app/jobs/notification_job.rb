# frozen_string_literal: true

class NotificationJob < ApplicationJob
  queue_as :default

  def perform(organization, title, message)
    ActionCable.server.broadcast("notifications_#{organization}", title: title, body: message)
  end
end
