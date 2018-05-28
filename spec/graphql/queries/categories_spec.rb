# frozen_string_literal: true

require 'rails_helper'

describe 'query categories(orgId: ID!, type: CategoryType): [Category!]!' do
  let(:query) do
    %(
      query GetOrganizationTypedCategories($orgId: ID!, $type: CategoryType) {
        categories(orgId: $orgId, type: $type) {
          id
          organizationId
          type
          name
        }
      }
    )
  end

  let(:org)       { create :organization, without_categories: true }
  let(:other_org) { create :organization, without_categories: true }
  let(:user)      { create :user, organization: [org, other_org] }

  let!(:income_category)  { create :category, :income,  organization: org }
  let!(:expense_category) { create :category, :expense, organization: org }
  let!(:other_category)   { create :category, :income,  organization: other_org }

  let(:context)   { { current_user: user } }
  let(:variables) { { orgId: org.id } }
  let(:result)    { CashboxSchema.execute(query, context: context, variables: variables).to_h }

  it 'returns categories for given organization' do
    expect(result['data']['categories'].size).to eq 2
    expect(result['data']['categories']).to match([
      {
        'id'             => income_category.id.to_s,
        'organizationId' => org.id.to_s,
        'type'           => income_category.type,
        'name'           => income_category.name,
      },
      {
        'id'             => expense_category.id.to_s,
        'organizationId' => org.id.to_s,
        'type'           => expense_category.type,
        'name'           => expense_category.name,
      },
    ])
  end

  context 'if type was provided' do
    let(:variables) { { orgId: org.id, type: 'Expense' } }

    it 'return categories for given organization and only with provided type' do
      expect(result['data']['categories'].size).to eq 1
      expect(result['data']['categories']).to match([
        {
          'id'             => expense_category.id.to_s,
          'organizationId' => org.id.to_s,
          'type'           => expense_category.type,
          'name'           => expense_category.name,
        },
      ])
    end
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
