# frozen_string_literal: true

class CashboxSchema < GraphQL::Schema
  query    Types::Query
  mutation Types::Mutation
end
