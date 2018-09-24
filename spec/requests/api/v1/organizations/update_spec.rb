# frozen_string_literal: true

require 'rails_helper'

describe 'PUT /api/organizations/#' do
  let(:path)    { api_organization_path(org) }
  let(:headers) { auth_header(user) }

  let(:org)  { create :organization }
  let(:user) { create :user, owned_organization: org }

  let(:name)     { generate(:organization_name) }
  let(:currency) { 'RUB' }

  let(:params) do
    {
      organization: {
        name:             name,
        default_currency: currency,
      },
    }
  end

  before do
    put path, params: params, headers: headers
  end

  it 'updates organization' do
    expect(response).to be_success

    org.reload
    expect(org.name).to             eq name
    expect(org.default_currency).to eq currency

    expect(json_body.organization).to be_organization_json(org)
  end

  context 'with wrong params' do
    let(:name) { '' }

    it 'returns error' do
      expect(response).not_to be_success

      expect(json_body.name).to eq ['can\'t be blank']
    end
  end

  context 'unauthenticated' do
    let(:headers) { {} }

    it 'return unauthorized error' do
      expect(response).to be_unauthorized
    end
  end

  context 'authenticated as not owner' do
    let(:user) { create :user, organization: org }

    it 'returns forbidden error' do
      expect(response).to be_forbidden
    end
  end
end
