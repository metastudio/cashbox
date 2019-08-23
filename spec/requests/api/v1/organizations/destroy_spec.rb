# frozen_string_literal: true

require 'rails_helper'

describe 'DELETE /api/organizations/#' do
  let(:path)    { api_organization_path(org) }
  let(:headers) { auth_header(user) }

  let(:org)  { create :organization }
  let(:user) { create :user, owned_organization: org }

  before do
    delete path, headers: headers
  end

  it 'deletes organization' do
    expect(response).to be_successful

    expect(json_body.organization).to be_organization_json(org)

    expect(Organization).not_to be_exists(org.id)
  end

  context 'authenticated as not owner' do
    let(:user) { create :user, organization: org }

    it 'returns forbidden error' do
      expect(response).to be_forbidden

      expect(Organization).to be_exists(org.id)
    end
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

      expect(Organization).to be_exists(org.id)
    end
  end
end
