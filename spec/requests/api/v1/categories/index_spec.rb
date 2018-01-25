require 'rails_helper'

describe 'GET /api/organizations/#/categories' do
  let(:path) { "/api/organizations/#{organization.id}/categories" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let!(:category1) { create :category, organization: organization }
  let!(:category2) { create :category, organization: organization }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { get path, headers: auth_header(owner) }

    it 'returns categories' do
      expect(json[0]).to include(
        'id' => category2.id,
        'name' => category2.name,
      )
      expect(json[1]).to include(
        'id' => category1.id,
        'name' => category1.name,
      )
    end
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(user) }

    it 'returns categories' do
      expect(response).to be_success

      expect(json[0]).to include(
        'id' => category2.id,
        'name' => category2.name,
      )
      expect(json[1]).to include(
        'id' => category1.id,
        'name' => category1.name,
      )
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { get path, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_success
      expect(json).to be_empty
    end
  end
end
