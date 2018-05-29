# frozen_string_literal: true

require 'rails_helper'

describe 'mutation updateCategory(id: ID!, category: CategoryInput!): UpdateCategoryPayload' do
  let(:query) do
    %(
      mutation UpdateCategory($categoryId: ID!, $category: CategoryInput!) {
        updateCategory(id: $categoryId, category: $category) {
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
  let!(:category)  { create :category, :income, organization: org }

  let(:type) { 'Expense' }
  let(:name) { generate :category_name }

  let(:category_params) do
    {
      type: type,
      name: name,
    }
  end

  let(:context)   { { current_user: user } }
  let(:variables) { { categoryId: category.id, category: category_params } }
  let(:result)    { CashboxSchema.execute(query, context: context, variables: variables).to_h }

  it 'updates category and return it' do
    expect(result['data']['updateCategory']['category']).to include({
      'id'             => category.id.to_s,
      'organizationId' => org.id.to_s,
      'type'           => type,
      'name'           => name,
    })
    expect(result['errors']).to be_blank

    category.reload

    expect(category.organization_id).to eq org.id
    expect(category.name).to           eq name
    expect(category.type).to           eq type
  end

  context 'if wrong category id was provided' do
    let(:variables) { { categoryId: 'wrong_id', category: category_params } }

    it 'returns error' do
      expect(result['data']['updateCategory']).to eq nil
      expect(result['errors'].first['message']).to match(/\ACouldn't find Category/)
    end
  end

  context 'if user is not associated with category organization' do
    let!(:category) { create :category, :income, organization: other_org }

    it 'returns error' do
      expect(result['data']['updateCategory']).to eq nil
      expect(result['errors'].first['message']).to match(/\ACouldn't find Category/)
    end
  end

  context 'if data was wrong' do
    let(:category_params) { { name: nil, type: nil } }

    it 'returns error' do
      expect(result['data']['updateCategory']).to eq nil
      expect(result['errors'].first['message']).to eq 'Invalid record'
      expect(result['errors'].first['validationErrors']).to include({
        type: ['can\'t be blank', ' is not a valid category type'],
        name: ['can\'t be blank'],
      })
    end
  end

  context 'if tries to update organization id for category' do
    let(:category_params) { { organizationId: other_org.id } }

    it 'returns error' do
      expect(result['data']).to eq nil
      expect(result['errors'].first['message']).to eq 'Variable category of type CategoryInput! was provided invalid value'
    end
  end

  context 'if user is not authenticated' do
    let(:context) { {} }

    it 'returns error' do
      expect(result['data']['updateCategory']).to eq nil
      expect(result['errors'].first['message']).to eq 'Authentication required.'
    end
  end
end
