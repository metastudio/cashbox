# frozen_string_literal: true

require 'rails_helper'

describe 'mutation createCategory(orgId: ID!, category: CategoryInput!): CreateCategoryPayload' do
  let(:query) do
    %(
      mutation CreateCategory($orgId: ID!, $category: CategoryInput!) {
        createCategory(orgId: $orgId, category: $category) {
          category {
            id
            organizationId
            type
            name
          }
        }
      }
    )
  end

  let!(:org)       { create :organization }
  let!(:other_org) { create :organization }
  let!(:user)      { create :user, organization: org }

  let(:type) { 'Income' }
  let(:name) { generate :category_name }

  let(:category_params) do
    {
      type: type,
      name: name,
    }
  end

  let(:context)   { { current_user: user } }
  let(:variables) { { orgId: org.id, category: category_params } }
  let(:result)    { CashboxSchema.execute(query, context: context, variables: variables).to_h }

  it 'creates category and return it' do
    expect(result['data']['createCategory']['category']).to include({
      'organizationId' => org.id.to_s,
      'type'           => type,
      'name'           => name,
    })
    expect(result['errors']).to be_blank

    category = Category.unscoped.last

    expect(category.organization_id).to eq org.id
    expect(category.name).to            eq name
    expect(category.type).to            eq type
  end

  context 'if wrong organization id was provided' do
    let(:variables) { { orgId: 'wrong_id', category: category_params } }

    it 'returns error' do
      expect(result['data']['createCategory']).to eq nil
      expect(result['errors'].first['message']).to match(/\ACouldn't find Organization/)
    end
  end

  context 'if user is not associated with given organization' do
    let(:variables) { { orgId: other_org.id, category: category_params } }

    it 'returns error' do
      expect(result['data']['createCategory']).to eq nil
      expect(result['errors'].first['message']).to match(/\ACouldn't find Organization/)
    end
  end

  context 'if data was wrong' do
    let(:category_params) { {} }

    it 'returns error' do
      expect(result['data']['createCategory']).to eq nil
      expect(result['errors'].first['message']).to eq 'Invalid record'
      expect(result['errors'].first['validationErrors']).to include({
        type: ['can\'t be blank', ' is not a valid category type'],
        name: ['can\'t be blank'],
      })
    end
  end

  context 'if user is not authenticated' do
    let(:context) { {} }

    it 'returns error' do
      expect(result['data']['createCategory']).to eq nil
      expect(result['errors'].first['message']).to eq 'Authentication required.'
    end
  end
end
