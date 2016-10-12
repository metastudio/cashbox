require 'rails_helper'

describe 'GET /api/organizations/#/customers/#' do
  let(:path) { "/api/organizations/#{organization.id}/customers/#{customer.id}" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let!(:customer) { create :customer, organization: organization }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { get path, headers: auth_header(owner) }

    it 'returns customer' do
      expect(response).to be_success

      expect(json).to include(
        'id' => customer.id,
        'name' => customer.name
      )
    end
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(user) }

    it 'returns customer' do
      expect(response).to be_success

      expect(json).to include(
        'id' => customer.id,
        'name' => customer.name
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
