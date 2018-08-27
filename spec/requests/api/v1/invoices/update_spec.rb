# frozen_string_literal: true

require 'rails_helper'

describe 'PUT /api/organizations/#/invoices/#' do
  let(:path) { "/api/organizations/#{organization.id}/invoices/#{invoice.id}" }

  let!(:user)          { create :user }
  let!(:bank_account)  { create :bank_account, organization: organization }
  let!(:customer1)     { create :customer, organization: organization }
  let!(:customer2)     { create :customer, organization: organization }

  let(:amount)    { Money.from_amount(100, bank_account.currency) }
  let(:number)    { '5' }
  let(:starts_at) { Date.current }
  let(:ends_at)   { 5.days.since.in_time_zone.to_date }
  let(:sent_at)   { Date.current }
  let(:paid_at)   { Date.current }

  let(:item1_customer)    { create :customer, organization: organization }
  let(:item1_amount)      { Money.from_amount(11.00) }
  let(:item1_description) { generate :invoice_item_description }
  let(:item1_hours)       { 3.5 }
  let(:item1_date)        { 10.days.ago.to_date }

  let(:item2_customer_name) { generate :customer_name }
  let(:item2_amount)        { Money.from_amount(13.00) }

  let!(:organization) { create :organization, with_user: user }
  let!(:invoice)      { create :invoice, organization: organization, customer: customer1, currency: 'USD' }

  let(:params) do
    {
      invoice: {
        customer_id:              customer2.id,
        currency:                 'USD',
        number:                   number,
        starts_at:                starts_at.as_json,
        ends_at:                  ends_at.as_json,
        sent_at:                  sent_at.as_json,
        paid_at:                  paid_at.as_json,
        invoice_items_attributes: {
          0 => {
            customer_id: item1_customer.id,
            amount:      item1_amount.to_s,
            description: item1_description,
            hours:       item1_hours.to_s,
            date:        item1_date.as_json,
          },
          1 => {
            customer_name: item2_customer_name,
            amount:        item2_amount.to_s,
          },
        }
      }
    }
  end

  context 'unauthenticated' do
    it { put(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as user' do
    before { put path, params: params, headers: auth_header(user) }

    it 'returns updated invoice' do
      expect(response).to be_success

      invoice.reload

      expect(invoice.organization_id).to    eq organization.id
      expect(invoice.currency).to           eq 'USD'
      expect(invoice.customer_id).to        eq customer2.id
      expect(invoice.number).to             eq number
      expect(invoice.amount).to             eq item1_amount + item2_amount
      expect(invoice.starts_at).to          eq starts_at
      expect(invoice.ends_at).to            eq ends_at
      expect(invoice.sent_at).to            eq sent_at
      expect(invoice.paid_at).to            eq paid_at
      expect(invoice.invoice_items.size).to eq 2

      item1 = invoice.invoice_items.ordered[0]
      expect(item1.currency).to    eq 'USD'
      expect(item1.customer_id).to eq item1_customer.id
      expect(item1.amount).to      eq item1_amount
      expect(item1.description).to eq item1_description
      expect(item1.hours).to       eq item1_hours
      expect(item1.date).to        eq item1_date

      item2 = invoice.invoice_items.ordered[1]
      expect(item2.currency).to                 eq 'USD'
      expect(item2.customer.name).to            eq item2_customer_name
      expect(item2.customer.organization_id).to eq organization.id
      expect(item2.amount).to                   eq item2_amount
      expect(item2.description).to              eq nil
      expect(item2.hours).to                    eq nil
      expect(item2.date).to                     eq nil

      expect(json).to include(
        'id'        => invoice.id,
        'number'    => number,
        'starts_at' => starts_at.as_json,
        'amount'    => (item1_amount + item2_amount).as_json,
        'ends_at'   => ends_at.as_json,
        'sent_at'   => sent_at.as_json,
        'paid_at'   => paid_at.as_json,
      )
    end

    context 'missing required params' do
      let(:ends_at) { nil }
      let(:item1_amount) { nil }
      let(:item2_customer_name) { nil }

      it 'returns error' do
        expect(response).not_to be_success

        expect(json).to include 'ends_at' => ["can't be blank", 'is not a date']
        expect(json).to include 'invoice_items' => {
          '0' => { 'amount' => ['is not a number', 'must be greater than 0'] },
          '1' => { 'description' => ['can\'t be blank'] },
        }
      end
    end
  end

  context 'authenticated as wrong user' do
    let!(:wrong_user) { create :user }

    before { put path, params: params, headers: auth_header(wrong_user) }

    it 'returns error' do
      expect(response).to_not be_success
      expect(json).to be_empty
    end
  end
end
