# frozen_string_literal: true

class Types::AuthToken < Types::BaseObject
  field :jwt, String, null: false, method: :jwt
end
