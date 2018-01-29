require 'rails_helper'

describe 'POST /api/organizations/#/customers' do
  let(:path) { "/api/organizations/#{organization.id}/customers" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let(:params) {
    {
      customer: {
        name: 'Test'
      }
    }
  }

  context 'unauthenticated' do
    it { post(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { post path, params: params, headers: auth_header(owner) }

    it 'returns created customer' do
      expect(response).to be_success

      expect(json).to include(
        'id' => Customer.last.id,
        'name' => 'Test'
      )
      expect(organization.customers.last.id).to eq Customer.last.id
    end

    context 'with wrong params' do
      let(:params) {
        { customer: {
            name: ''
          }
        }
      }

      it 'returns error' do
        expect(response).to_not be_success

        expect(json).to include "name" => ["can't be blank"]
      end
    end
  end

  context 'authenticated as user' do
    before { post path, params: params, headers: auth_header(user) }

    it 'returns created customer' do
      expect(response).to be_success

      expect(json).to include(
        'id' => Customer.last.id,
        'name' => 'Test'
      )
      expect(organization.customers.last.id).to eq Customer.last.id
    end
  end
end
