# frozen_string_literal: true

class Types::CategoryType < GraphQL::Schema::Enum
  graphql_name 'CategoryType'

  value 'Income',  'Income category'
  value 'Expense', 'Expense category'
end
