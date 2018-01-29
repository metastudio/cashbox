class MainPageRefreshJob < ApplicationJob
  queue_as :default

  def perform(organization, data)
    ActionCable.server.broadcast("main_page_#{organization}", data)
  end
end
