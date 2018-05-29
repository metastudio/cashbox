# frozen_string_literal: true

class Types::Organization < Types::BaseObject
  field :id, ID, null: false

  field :name,             String, null: false
  field :default_currency, String, null: true

  field :created_at, Types::DateTime, null: false
  field :updated_at, Types::DateTime, null: false
end
