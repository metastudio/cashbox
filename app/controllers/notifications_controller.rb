class NotificationsController < ApplicationController
  include Tubesock::Hijack

  def stream
    if user_signed_in?
      organizations = current_user.organizations.ids
      hijack do |tubesock|
        redis_thread = Thread.new do
          Redis.new.subscribe organizations do |on|
            on.message do |channel, message|
              tubesock.send_data message
            end
          end
        end

        tubesock.onclose do
          redis_thread.kill
        end
      end
    end
  end

end