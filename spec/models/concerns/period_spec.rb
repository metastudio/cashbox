# frozen_string_literal: true

require 'rails_helper'

describe Period do
  subject { Invoice }

  before { Timecop.travel(2012, 12, 12) }

  describe 'period_ends' do
    it 'for current-month return 1 dec and 31 dec 2012' do
      period = 'current-month'
      begining, ending = subject.send(:period_ends, period)
      expect(begining).to eq(Date.parse('Sat, 01 Dec 2012'))
      expect(ending).to eq(Date.parse('Mon, 31 Dec 2012'))
    end

    it 'for last-3-months return 12 sep and 31 dec 2012' do
      period = 'last-3-months'
      begining, ending = subject.send(:period_ends, period)
      expect(begining).to eq(Date.parse('Wed, 12 Sep 2012'))
      expect(ending).to eq(Date.parse('Mon, 31 Dec 2012'))
    end

    it 'for prev-month return 1 nov and 30 nov 2012' do
      period = 'prev-month'
      begining, ending = subject.send(:period_ends, period)
      expect(begining).to eq(Date.parse('Thu, 01 Nov 2012'))
      expect(ending).to eq(Date.parse('Fri, 30 Nov 2012'))
    end

    it 'for this-year return 1 jan and 31 dec 2012' do
      period = 'this-year'
      begining, ending = subject.send(:period_ends, period)
      expect(begining).to eq(Date.parse('Sun, 01 Jan 2012'))
      expect(ending).to eq(Date.parse('Mon, 31 Dec 2012'))
    end

    it 'for quarter return 1 oct and 31 dec 2012' do
      period = 'quarter'
      begining, ending = subject.send(:period_ends, period)
      expect(begining).to eq(Date.parse('Mon, 01 Oct 2012'))
      expect(ending).to eq(Date.parse('Mon, 31 Dec 2012'))
    end
  end

  describe 'period' do
    let(:organization) { create :organization }
    let!(:invoice) { create :invoice, ends_at: Date.new(2012, 12, 1), organization: organization }
    let!(:wizened_invoice) { create :invoice, ends_at: Date.new(2012, 7, 12), organization: organization }
    let!(:transaction) { create :transaction, date: Date.new(2012, 12, 1), organization: organization }
    let(:period) { 'quarter' }

    it 'invoices period have invoice and don\'t have wizened_invoice' do
      expect(organization.invoices.period(period)).to include(invoice)
      expect(organization.invoices.period(period)).to_not include(wizened_invoice)
    end

    it 'transactions period have transaction' do
      expect(organization.transactions.period(period)).to include(transaction)
    end
  end
end
