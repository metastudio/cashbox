# frozen_string_literal: true

require 'rails_helper'

describe 'POST /api/organizations' do
  let(:path)    { api_organizations_path }
  let(:headers) { auth_header(user) }

  let(:user) { create :user }

  let(:name)     { generate :organization_name }
  let(:currency) { 'USD' }

  let(:params) do
    {
      organization: {
        name:             name,
        default_currency: currency,
      },
    }
  end

  before do
    post path, params: params, headers: headers
  end

  it 'returns created organization' do
    expect(response).to be_successful

    org = Organization.unscoped.last
    expect(org.name).to             eq name
    expect(org.default_currency).to eq currency

    user.reload
    member = user.members.find_by!(organization_id: org.id)
    expect(member.role).to eq 'owner'

    expect(json_body.organization).to be_organization_json(org)
  end

  context 'with wrong params' do
    let(:name) { '' }

    it 'returns error' do
      expect(response).not_to be_successful

      expect(json_body.name).to eq ['can\'t be blank']
    end
  end

  context 'unauthenticated' do
    let(:headers) { {} }

    it 'return unauthorized error' do
      expect(response).to be_unauthorized
    end
  end
end
