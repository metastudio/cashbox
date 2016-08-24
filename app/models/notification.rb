module Notification

  def notify(organization, title, body)
    data = {
      title: title,
      body: body,
    }.to_json
    Redis.new.publish organization, data
  end

end