# frozen_string_literal: true

require 'rails_helper'

describe ConvertedMoneyPresenter do
  let!(:money) { Money.new(100, 'USD') }
  let!(:new_currency) { 'RUB' }
  subject { ConvertedMoneyPresenter.new(money, new_currency) }

  before { Money.default_bank.add_rate('USD', 'RUB', 63) }

  describe '#rate' do
    it 'return current rate' do
      expect(subject.send(:rate)).to eq(63)
    end
  end

  describe '#new_amount' do
    it 'return new amount' do
      expect(subject.send(:new_amount)).to eq(Money.new(6300, 'RUB'))
    end
  end

  describe '#updated_at' do
    it 'return updated date' do
      expect(subject.send(:updated_at)).to eq(Date.current)
    end
  end

  describe '#present' do
    it 'return json' do
      expect(subject.present).to eq({
        amount: Money.new(6300, 'RUB'),
        old_amount: money,
        rate: 63,
        updated_at: Date.current,
        total: Money.new(6300, 'RUB')
      })
    end
  end
end
