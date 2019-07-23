# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations' do
  let(:path)    { api_organizations_path }
  let(:headers) { auth_header(user) }

  let(:user) { create :user }

  let!(:org1)      { create :organization, user: user }
  let!(:org2)      { create :organization, owner: user }
  let!(:other_org) { create :organization, user: create(:user) }

  before do
    get path, headers: headers
  end

  it 'returns organizations' do
    expect(response).to be_successful

    expect(json_body.organizations.size).to eq 2
    expect(json_body.organizations.map(&:id)).to eq [org1, org2].map(&:id)

    org1_json = json_body.organizations.find{ |j| j.id == org1.id }
    expect(org1_json).to be_organization_json(org1)

    org2_json = json_body.organizations.find{ |j| j.id == org2.id }
    expect(org2_json).to be_organization_json(org2)
  end

  context 'unauthenticated' do
    let(:headers) { {} }

    it 'return unauthorized error' do
      expect(response).to be_unauthorized
    end
  end
end
