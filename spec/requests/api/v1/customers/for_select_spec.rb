require 'rails_helper'

describe 'GET /api/organizations/#/customers/for_select' do
  let(:path) { "/api/organizations/#{organization.id}/customers/for_select" }

  let!(:owner) { create :user }
  let!(:user) { create :user }
  let!(:organization) { create :organization, owner: owner, with_user: user }
  let!(:customer1) { create :customer, organization: organization }
  let!(:customer2) { create :customer, organization: organization }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as owner' do
    before { get path, headers: auth_header(owner) }

    it 'returns customers for select' do
      expect(json[0]).to include(
        'value' => customer2.id,
        'label' => customer2.name,
      )
      expect(json[1]).to include(
        'value' => customer1.id,
        'label' => customer1.name,
      )
    end
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(user) }

    it 'returns customers for select' do
      expect(response).to be_success

      expect(json[0]).to include(
        'value' => customer2.id,
        'label' => customer2.name,
      )
      expect(json[1]).to include(
        'value' => customer1.id,
        'label' => customer1.name,
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
