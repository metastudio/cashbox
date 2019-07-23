# frozen_string_literal: true

require 'rails_helper'

describe 'GET /api/organizations/#/bank_accounts' do
  let(:path) { "/api/organizations/#{organization.id}/bank_accounts" }

  let!(:user) { create :user }
  let!(:organization) { create :organization, without_bank_accounts: true, with_user: user }
  let!(:bank_account1) { create :bank_account, organization: organization, position: 3 }
  let!(:bank_account2) { create :bank_account, organization: organization, position: 2 }
  let!(:bank_account3) { create :bank_account, organization: organization, position: 1, visible: false }

  context 'unauthenticated' do
    it { get(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as user' do
    before { get path, headers: auth_header(user) }

    it 'returns bank_accounts' do
      expect(response).to be_successful

      expect(json.size).to eq 3
      expect(json[0]).to include(
        'id'              => bank_account3.id,
        'name'            => bank_account3.name,
        'currency'        => bank_account3.currency,
        'description'     => bank_account3.description,
        'invoice_details' => bank_account3.invoice_details,
        'balance'         => bank_account3.balance.as_json,
        'residue'         => bank_account3.residue.as_json,
      )
      expect(json[1]).to include(
        'id'              => bank_account2.id,
        'name'            => bank_account2.name,
        'currency'        => bank_account2.currency,
        'description'     => bank_account2.description,
        'invoice_details' => bank_account2.invoice_details,
        'balance'         => bank_account2.balance.as_json,
        'residue'         => bank_account2.residue.as_json,
      )
      expect(json[2]).to include(
        'id'              => bank_account1.id,
        'name'            => bank_account1.name,
        'currency'        => bank_account1.currency,
        'description'     => bank_account1.description,
        'invoice_details' => bank_account1.invoice_details,
        'balance'         => bank_account1.balance.as_json,
        'residue'         => bank_account1.residue.as_json,
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
