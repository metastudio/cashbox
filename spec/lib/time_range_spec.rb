require 'spec_helper'

describe 'TimeRange' do

  describe "format" do
    subject { TimeRange::format(Time.now, period) }

    context 'this year' do
      before do
        Timecop.travel(2012,12,12)
      end

      context 'current-month' do
        let(:period) { 'current-month' }
        it { expect(subject).to eq "Dec 1st - Dec 12th" }
      end

      context 'previous month' do
        let(:period) { 'previous-month' }
        it { expect(subject).to eq "Nov 1st - Nov 30th" }
      end

      context 'quarter' do
        let(:period) { 'current-quarter' }
        it { expect(subject).to eq "Oct 1st - Dec 12th" }
      end

      context 'year' do
        let(:period) { 'this-year' }
        it { expect(subject).to eq "Jan 1st - Dec 12th" }
      end

      context 'last 3 month' do
        let(:period) { 'last-3-months' }
        it { expect(subject).to eq "Sep 12th - Dec 12th" }
      end
    end

    context 'over year' do
      before do
        Timecop.travel(2013,1,12)
      end

      context 'previous month' do
        let(:period) { 'previous-month' }
        it { expect(subject).to eq "Dec 1st, 2012 - Dec 31st" }
      end

      context 'last 3 month' do
        let(:period) { 'last-3-months' }
        it { expect(subject).to eq "Oct 12th, 2012 - Jan 12th" }
      end
    end

  end
end
