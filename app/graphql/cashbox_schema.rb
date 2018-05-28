# frozen_string_literal: true

class CashboxSchema < GraphQL::Schema
  query    Types::Query
  mutation Types::Mutation
end

GraphQL::Errors.configure(CashboxSchema) do
  rescue_from ActiveRecord::RecordNotFound do |exception, _obj, _args, ctx|
    ctx.add_error(GraphQL::ExecutionError.new(exception.message))
  end

  # rescue_from ActiveRecord::RecordInvalid do |exception|
  #   GraphQL::ExecutionError.new(exception.record.errors.full_messages.join("\n"))
  # end

  # rescue_from StandardError do |exception|
  #   GraphQL::ExecutionError.new("Please try to execute the query for this field later")
  # end
end
