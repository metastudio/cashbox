require 'rails_helper'

describe 'PUT /api/organizations/#/customers/#' do
  let(:path) { "/api/organizations/#{organization.id}/customers/#{customer.id}" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let!(:customer) { create :customer, organization: organization }
  let(:params) {
    {
      customer: {
        name: 'New Name'
      }
    }
  }

  context 'unauthenticated' do
    it { put(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { put path, params: params, headers: auth_header(owner) }

    it 'returns updated customer' do
      expect(response).to be_successful
      customer.reload
      expect(json).to include(
        'id' => customer.id,
        'name' => 'New Name'
      )
    end
  end

  context 'authenticated as user' do
    before { put path, params: params, headers: auth_header(user) }

    it 'returns updated customer' do
      expect(response).to be_successful
      customer.reload
      expect(json).to include(
        'id' => customer.id,
        'name' => 'New Name'
      )
    end

    context 'with wrong params' do
      let(:params) {
        {
          customer: {
            name: ''
          }
        }
      }

      it 'returns error' do
        expect(response).to_not be_successful
        expect(json).to include "name" => ["can't be blank"]
      end
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { put path, params: params, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_successful
      expect(json).to be_empty
    end
  end
end
