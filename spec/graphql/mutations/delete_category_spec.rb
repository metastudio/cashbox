# frozen_string_literal: true

require 'rails_helper'

describe 'mutation deleteCategory(id: ID!): DeleteCategoryPayload' do
  let(:query) do
    %(
      mutation DeleteCategory($categoryId: ID!) {
        deleteCategory(id: $categoryId) {
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

  let(:context)   { { current_user: user } }
  let(:variables) { { categoryId: category.id } }
  let(:result)    { CashboxSchema.execute(query, context: context, variables: variables).to_h }

  it 'deletes category and return deleted category' do
    expect(result['data']['deleteCategory']['category']).to include({
      'id'             => category.id.to_s,
      'organizationId' => org.id.to_s,
      'type'           => category.type,
      'name'           => category.name,
    })
    expect(result['errors']).to be_blank

    expect(Category).not_to be_exists(category.id)
  end

  context 'if wrong category id was provided' do
    let(:variables) { { categoryId: 'wrong_id' } }

    it 'returns error' do
      expect(result['data']['deleteCategory']).to eq nil
      expect(result['errors'].first['message']).to match(/\ACouldn't find Category/)

      expect(Category).to be_exists(category.id)
    end
  end

  context 'if user is not associated with category organization' do
    let!(:category) { create :category, :income, organization: other_org }

    it 'returns error' do
      expect(result['data']['deleteCategory']).to eq nil
      expect(result['errors'].first['message']).to match(/\ACouldn't find Category/)

      expect(Category).to be_exists(category.id)
    end
  end

  context 'if user is not authenticated' do
    let(:context) { {} }

    it 'returns error' do
      expect(result['data']['deleteCategory']).to eq nil
      expect(result['errors'].first['message']).to eq 'Authentication required.'

      expect(Category).to be_exists(category.id)
    end
  end
end
