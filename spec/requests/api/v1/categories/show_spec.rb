require 'rails_helper'

describe 'GET /api/organizations/#/categories/#' do
  let(:path) { "/api/organizations/#{organization.id}/categories/#{category.id}" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let!(:category) { create :category, organization: organization }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { get path, headers: auth_header(owner) }

    it 'returns category' do
      expect(response).to be_successful

      expect(json).to include(
        'id' => category.id,
        'name' => category.name,
        'type' => category.type
      )
    end
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(user) }

    it 'returns category' do
      expect(response).to be_successful

      expect(json).to include(
        'id' => category.id,
        'name' => category.name,
        'type' => category.type
      )
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { get path, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_successful
      expect(json).to be_empty
    end
  end
end
