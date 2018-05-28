# frozen_string_literal: true

require 'rails_helper'

describe 'query userOrganizations: [Organization!]!' do
  let(:query) do
    %(
      query GetUserOrganizations {
        userOrganizations {
          id
          name
          defaultCurrency
        }
      }
    )
  end

  let!(:org1)      { create :organization }
  let!(:org2)      { create :organization }
  let!(:other_org) { create :organization }

  let(:user)      { create :user, organization: [org1, org2] }

  let(:context)   { { current_user: user } }
  let(:result)    { CashboxSchema.execute(query, context: context).to_h }

  it 'returns organizations associated with current user' do
    expect(result['data']['userOrganizations'].size).to eq 2
    expect(result['data']['userOrganizations']).to match([
      {
        'id'              => org1.id.to_s,
        'name'            => org1.name,
        'defaultCurrency' => org1.default_currency,
      },
      {
        'id'              => org2.id.to_s,
        'name'            => org2.name,
        'defaultCurrency' => org2.default_currency,
      },
    ])
  end

  context 'if user doesn\'t have any associated organizations' do
    let(:user) { create :user }

    it 'return empty array' do
      expect(result['data']['userOrganizations'].size).to eq 0
    end
  end
end
