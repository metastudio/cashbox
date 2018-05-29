# frozen_string_literal: true

if Rails.env.development?
  GraphiQL::Rails.config.headers['Authorization'] = ->(_context){ AppConfig.graphiql_authorization_header }
end
