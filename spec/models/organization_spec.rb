# == Schema Information
#
# Table name: organizations
#
#  id               :integer          not null, primary key
#  name             :string(255)      not null
#  created_at       :datetime
#  updated_at       :datetime
#  default_currency :string(255)      default("USD")
#

require 'spec_helper'

describe Organization do
  context "assocation" do
    it { should have_many(:owners).class_name('User').through(:members) }
    it { should have_many(:members).dependent(:destroy) }
    it { should have_many(:bank_accounts).dependent(:destroy) }
    it { should have_many(:users).through(:members) }
    it { should have_many(:categories).dependent(:destroy) }
    it { should have_many(:transactions).through(:bank_accounts) }
    it { should have_many(:customers).dependent(:destroy) }
  end

  context "validation" do
    it { should validate_presence_of(:name) }
  end

  describe '#exchange_rates' do
    before do
      Dictionaries.currencies << "EUR" unless Dictionaries.currencies.include?("EUR")
    end

    after do
      Dictionaries.currencies.delete("EUR") if Dictionaries.currencies.include?("EUR")
    end

    context 'with updated Dictionary for including EUR' do
      let!(:org) { create :organization }
      let!(:ba)  { create :bank_account, currency: "USD", organization: org }
      let!(:ba2) { create :bank_account, currency: "RUB", organization: org }
      let!(:ba3) { create :bank_account, currency: "EUR", organization: org }

      # ToDo needs to be updated when we change default bank
      # should contain then each-to-each currency keys e.x. USD_TO_EUR
      # not only within RUB
      it "return only present currency rates" do
        expect(org.exchange_rates.keys).to eq ["RUB_TO_USD", "USD_TO_RUB", "RUB_TO_EUR", "EUR_TO_RUB"]
      end
    end
  end

  describe '#ordered_curr' do
    let!(:org) { create :organization, default_currency: curr }
    let!(:ba)  { create :bank_account, currency: 'USD', organization: org }
    let!(:ba2) { create :bank_account, currency: 'RUB', organization: org }

    context 'when def curr = USD' do
      let(:curr) { 'USD' }
      it 'is correct' do
        expect(org.ordered_curr).to eq [curr, 'RUB']
      end
    end

    context 'when def curr = RUB' do
      let(:curr) { 'RUB' }
      it 'is correct' do
        expect(org.ordered_curr).to eq [curr, 'USD']
      end
    end
  end
end
