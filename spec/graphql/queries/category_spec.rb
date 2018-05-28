# frozen_string_literal: true

require 'rails_helper'

describe 'query category(id: ID!): Category!' do
  let(:query) do
    %(
      query GetCategory($categoryId: ID!) {
        category(id:$categoryId) {
          id
          organizationId
          type
          name
        }
      }
    )
  end

  let(:org)  { create :organization }
  let(:user) { create :user, organization: org }

  let(:category) { create :category, organization: org }

  let(:variables) { { categoryId: category.id } }
  let(:context)   { { current_user: user } }

  it 'returns category with given id' do
    result = CashboxSchema.execute(query, context: context, variables: variables).to_h

    expect(result['data']['category']).to include({
      'id'             => category.id.to_s,
      'organizationId' => org.id.to_s,
      'type'           => category.type,
      'name'           => category.name,
    })
  end

  context 'if category doesn\'t exist' do
    let(:variables) { { categoryId: 'wrong_id' } }

    it 'returns error' do
      result = CashboxSchema.execute(query, context: context, variables: variables).to_h

      expect(result['data']).to eq nil
      expect(result['errors'].first['message']).to match(/\ACouldn't find Category/)
    end
  end

  context 'if user doesn\'t have access to category organization' do
    let(:user) { create :user }

    it 'returns error' do
      result = CashboxSchema.execute(query, context: context, variables: variables).to_h

      expect(result['data']).to eq nil
      expect(result['errors'].first['message']).to match(/\ACouldn't find Category/)
    end
  end
end
