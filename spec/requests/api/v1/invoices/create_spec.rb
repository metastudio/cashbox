# frozen_string_literal: true

require 'rails_helper'

describe 'POST /api/organizations/#/invoices' do
  let(:path) { api_organization_invoices_path(organization) }

  let(:user) { create :user }
  let(:organization) { create :organization, with_user: user }

  let(:item2_customer)   { create :customer, organization: organization}

  let(:invoice_customer) { create :customer, organization: organization}
  let(:number)           { '5' }
  let(:starts_at)        { Date.current }
  let(:ends_at)          { 5.days.since.in_time_zone.to_date }
  let(:sent_at)          { Time.current }
  let(:paid_at)          { Time.current }

  let(:item1_customer)   { create :customer, organization: organization }
  let(:item1_amount)      { Money.from_amount(11.00) }
  let(:item1_description) { generate :invoice_item_description }
  let(:item1_hours)       { 3.5 }
  let(:item1_date)        { 10.days.ago.to_date }

  let(:item2_customer_name) { generate :customer_name }
  let(:item2_amount)        { Money.from_amount(13.00) }

  let(:params) do
    {
      invoice: {
        customer_name:            invoice_customer.name,
        number:                   number,
        starts_at:                starts_at.as_json,
        ends_at:                  ends_at.as_json,
        sent_at:                  sent_at.as_json,
        paid_at:                  paid_at.as_json,
        invoice_items_attributes: {
          1 => {
            customer_id: item1_customer.id,
            amount:      item1_amount.to_s,
            description: item1_description,
            hours:       item1_hours.to_s,
            date:        item1_date.as_json,
          },
          2 => {
            customer_name: item2_customer_name,
            amount:        item2_amount.to_s,
          },
        }
      }
    }
  end

  context 'unauthenticated' do
    it { post(path) && expect(response).to(be_unauthorized) }
  end

  context 'authenticated as member' do
    before { post path, params: params, headers: auth_header(user) }

    it 'returns created invoice' do
      expect(response).to be_success

      invoice = Invoice.unscoped.last

      expect(invoice.organization_id).to    eq organization.id
      expect(invoice.customer_id).to        eq invoice_customer.id
      expect(invoice.number).to             eq number
      expect(invoice.amount).to             eq item1_amount + item2_amount
      expect(invoice.starts_at).to          be_within(1.second).of(starts_at)
      expect(invoice.ends_at).to            be_within(1.second).of(ends_at)
      expect(invoice.sent_at).to            be_within(1.second).of(sent_at)
      expect(invoice.paid_at).to            be_within(1.second).of(paid_at)
      expect(invoice.invoice_items.size).to eq 2

      item1 = invoice.invoice_items.ordered[0]
      expect(item1.customer_id).to eq item1_customer.id
      expect(item1.amount).to      eq item1_amount
      expect(item1.description).to eq item1_description
      expect(item1.hours).to       eq item1_hours
      expect(item1.date).to        eq item1_date

      item2 = invoice.invoice_items.ordered[1]
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

      it 'returns error' do
        expect(response).not_to be_success

        expect(json).to include 'ends_at'  => ['can\'t be blank', 'is not a date']
      end
    end
  end
end
