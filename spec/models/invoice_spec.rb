# == Schema Information
#
# Table name: invoices
#
#  id              :integer          not null, primary key
#  organization_id :integer          not null
#  customer_id     :integer          not null
#  starts_at       :date
#  ends_at         :date             not null
#  currency        :string           default("USD"), not null
#  amount_cents    :integer          default(0), not null
#  sent_at         :datetime
#  paid_at         :datetime
#  created_at      :datetime
#  updated_at      :datetime
#  number          :string
#

require 'rails_helper'

describe Invoice do
  context 'association' do
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to belong_to(:customer) }
    it { is_expected.to have_many(:invoice_items).dependent(:destroy) }
  end

  context 'validation' do
    it { is_expected.to validate_presence_of(:organization) }
    it { is_expected.to validate_presence_of(:ends_at) }
    it { is_expected.to validate_presence_of(:currency) }
    it { is_expected.to validate_presence_of(:customer_name) }
    it { is_expected.to validate_numericality_of(:amount).
      is_greater_than(0).is_less_than_or_equal_to(Dictionaries.money_max) }
    it { is_expected.to validate_inclusion_of(:currency).in_array(Dictionaries.currencies) }

    context 'check ends_at after starts_at if starts_at present' do
      let!(:org)      { create :organization }
      let!(:customer) { create :customer }
      let(:invoice)   { build :invoice, customer_name: customer.name,
        organization: org, starts_at: Date.current - 1.days, ends_at: Date.current }
      let(:invoice1)  { build :invoice, customer_name: customer.name,
        organization: org, starts_at: Date.current + 2.days, ends_at: Date.current + 1.days  }
      let(:invoice2)  { build :invoice, customer_name: customer.name,
        organization: org, starts_at: nil, ends_at: Date.current + 3.days  }

      it 'Dont show errors' do
        invoice.valid?
        expect(invoice.errors[:ends_at]).to_not include("must be after or equal to #{I18n.l(invoice.starts_at)}")
      end
      it 'Show error on ends_at' do
        invoice1.valid?
        expect(invoice1.errors[:ends_at]).to include("must be after or equal to #{I18n.l(invoice1.starts_at)}")
      end
      it 'Dont show errors' do
        invoice2.valid?
        expect(invoice2.errors[:ends_at]).to_not include("must be after or equal to")
      end
    end

    context 'strip invoice number' do
      let(:invoice) { create :invoice, number: '   test test   ' }

      it 'has striped invoice number' do
        expect(invoice.number).to eq 'test test'
      end
    end
  end

  describe '#send_notification' do
    ActiveJob::Base.queue_adapter = :test
    before { ActiveJob::Base.queue_adapter.enqueued_jobs = [] }
    let!(:invoice) { create :invoice }

    it 'send notification after creation' do
      expect(NotificationJob).to have_been_enqueued.with(
        invoice.organization.name,
        "Invoice was added",
        "Invoice was added to organization #{invoice.organization.name}"
      )
    end
  end
end
