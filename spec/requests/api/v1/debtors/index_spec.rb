# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/debtors' do
  let(:path) { api_organization_debtors_path(org) }

  let(:user) { create :user }
  let(:org) { create :organization, with_user: user }
  let!(:invoice1) { create :invoice, organization: org }
  let!(:invoice2) { create :invoice }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated' do
    before { get path, headers: auth_header(user) }

    it 'returns debtors of current organization' do
      expect(json['debtors'].size).to eq 1

      expect(json['debtors'][0]).to include(
        'id'    => invoice1.customer.id,
        'name'  => invoice1.customer.to_s,
      )
    end

    it 'return total for all debtors in default currency' do
      expect(json['total']).not_to be_blank
    end

    it 'return summs by currencies for all debtors' do
      expect(json['totals_by_currency'][0]).to include(
        'amount' => JSON.parse(invoice1.amount.to_json)
      )
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { get path, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to be_not_found # we can't find organization with given id for current user
    end
  end
end
