module Requests
  module JsonHelpers
    def json
      @json ||= JSON.parse(response.body)
    end

    def auth_token(user)
      Knock::AuthToken.new(payload: { sub: user.id }).token if user.present?
    end

    def auth_header(user, headers = {})
      { 'Authorization': "Bearer #{auth_token(user)}" }.merge(headers)
    end
  end
end
