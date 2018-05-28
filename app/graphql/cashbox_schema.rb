# frozen_string_literal: true

class CashboxSchema < GraphQL::Schema
  query    Types::QueryType
  mutation Types::MutationType
end
