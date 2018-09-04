# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#' do
  let(:path)    { api_organization_path(org) }
  let(:headers) { auth_header(user) }

  let(:org) { create :organization }
  let(:user) { create :user, organization: org }

  before do
    get path, headers: headers
  end

  it 'returns organization' do
    expect(response).to be_success

    expect(json_body.organization).to be_organization_json(org)
  end

  context 'unauthenticated' do
    let(:headers) { {} }

    it 'return unauthorized error' do
      expect(response).to be_unauthorized
    end
  end

  context 'authenticated as user not associated with organization' do
    let(:user) { create :user }

    it 'returns not found error' do
      expect(response).to be_not_found
    end
  end
end
