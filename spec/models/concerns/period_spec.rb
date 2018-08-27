# frozen_string_literal: true

require 'rails_helper'

describe Period do
  before { Timecop.travel(2012, 12, 12) }
  after  { Timecop.return }

  describe '#period_ends' do
    subject { Invoice.send(:date_range, period) }

    context 'for current-month' do
      let(:period) { 'current-month' }

      it { is_expected.to eq Date.parse('2012-12-01')..Date.parse('2012-12-31') }
    end

    context 'for last-month' do
      let(:period) { 'last-month' }

      it { is_expected.to eq Date.parse('2012-11-01')..Date.parse('2012-11-30') }
    end

    context 'for last-3-months' do
      let(:period) { 'last-3-months' }

      it { is_expected.to eq Date.parse('2012-09-12')..Date.parse('2012-12-12') }
    end

    context 'for current-quarter' do
      let(:period) { 'current-quarter' }

      it { is_expected.to eq Date.parse('2012-10-01')..Date.parse('2012-12-31') }
    end

    context 'for last-quarter' do
      let(:period) { 'last-quarter' }

      it { is_expected.to eq Date.parse('2012-07-01')..Date.parse('2012-09-30') }
    end

    context 'for current-year' do
      let(:period) { 'current-year' }

      it { is_expected.to eq Date.parse('2012-01-01')..Date.parse('2012-12-31') }
    end

    context 'for last-year' do
      let(:period) { 'last-year' }

      it { is_expected.to eq Date.parse('2011-01-01')..Date.parse('2011-12-31') }
    end
  end

  describe '#period' do
    subject { organization.invoices.period(period) }

    let(:organization) { create :organization }

    let!(:invoice)         { create :invoice, ends_at: Date.new(2012, 12, 1), organization: organization }
    let!(:wizened_invoice) { create :invoice, ends_at: Date.new(2012, 7, 12), organization: organization }

    let(:period) { 'current-quarter' }

    it 'return data only for requested period' do
      is_expected.to include(invoice)
      is_expected.not_to include(wizened_invoice)
    end
  end
end
