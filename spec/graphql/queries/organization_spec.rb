# frozen_string_literal: true

require 'rails_helper'

describe 'query organization(id: ID!): Organization!' do
  let(:query) do
    %(
      query GetOrganization($orgId: ID!) {
        organization(id: $orgId) {
          id
          name
          defaultCurrency
        }
      }
    )
  end

  let!(:org) { create :organization }

  let(:user) { create :user, organization: org }

  let(:variables) { { orgId: org.id } }
  let(:context)   { { current_user: user } }
  let(:result)    { CashboxSchema.execute(query, context: context, variables: variables).to_h }

  it 'returns organization with given id' do
    expect(result['data']['organization']).to include({
      'id'              => org.id.to_s,
      'name'            => org.name,
      'defaultCurrency' => org.default_currency,
    })
  end

  context 'if organization doesn\'t exist' do
    let(:variables) { { orgId: 'wrong_id' } }

    it 'returns error' do
      expect(result['data']).to eq nil
      expect(result['errors'].first['message']).to match(/\ACouldn't find Organization/)
    end
  end

  context 'if user doesn\'t have access to organization' do
    let(:user) { create :user }

    it 'returns error' do
      expect(result['data']).to eq nil
      expect(result['errors'].first['message']).to match(/\ACouldn't find Organization/)
    end
  end
end
