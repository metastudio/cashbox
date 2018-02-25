require 'rails_helper'

describe 'POST api/invoices' do
  let(:path) { '/api/invoices' }
  let(:user) { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:customer) { create :customer, organization: organization}
  let(:amount) { Money.new(1000) }
  let(:number) { '5' }
  let(:starts_at) { Date.today }
  let(:ends_at) { 5.days.since.in_time_zone.to_date }
  let!(:sent_at) { Time.zone.now }
  let!(:paid_at) { Time.zone.now }

  let(:first_item_amount) { Money.new(1100) }
  let(:last_item_amount) { Money.new(1100) }

  let(:params){
    {
      invoice:  {
        customer_id: customer.id,
        number: number,
        amount: amount,
        starts_at: starts_at,
        ends_at: ends_at,
        sent_at: sent_at,
        paid_at: paid_at
      }
    }
  }

  context 'unauthenticated' do
    it { post(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as member' do
    before { post path, params: params, headers: auth_header(user) }

    it 'returns created invoice' do
      expect(response).to be_success

      expect(json).to include(
        'id' => Invoice.last.id,
        'number' => number,
        'starts_at' => starts_at.iso8601,
        'amount' => money_with_symbol(amount),
        'ends_at' => ends_at.iso8601
      )

      expect(Time.parse(json['sent_at']).to_i).to eq sent_at.to_i
      expect(Time.parse(json['paid_at']).to_i).to eq sent_at.to_i
    end

    context 'missing required params' do
      let(:ends_at) { nil }
      let(:amount) { nil }

      it 'returns error' do
        expect(response).to_not be_success

        expect(json).to include "amount" => ["must be greater than 0"]
        expect(json).to include "ends_at" => ["can't be blank", "is not a date"]
      end
    end
  end
end
