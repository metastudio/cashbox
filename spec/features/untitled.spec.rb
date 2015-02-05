require 'spec_helper'

describe 'create transfer transaction', js: true do
  let!(:user)         { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:ba1)          { create :bank_account, organization: organization,
    balance: 50000 }
  let!(:ba2)          { create :bank_account, organization: organization,
    balance: 99999 }

  let(:ba1_name)      { ba1.name }
  let(:ba2_name)      { ba2.name }

  let(:amount)        { 123.23 }
  let(:comission)     { 0.25 }
  let(:comment)       { "Test transaction" }

  let!(:ba1_new_amount)   { ba1.amount - Money.new(amount + comission, ba1.currency) }
  let!(:ba2_new_amount)   { ba2.amount + Money.new(amount, ba2.currency) }

  let(:transactions)  { organization.transactions.where(
    bank_account_id: [ba1.id, ba2.id]) }

    context "recalculates sidebar" do
      it "from account" do
        expect(subject).
          to have_css("#bank_account_#{ba_1.id} td.amount",
            text: humanized_money_with_symbol(ba1_new_amount))
      end

      it "to account" do
        expect(subject).
          to have_css("#bank_account_#{ba2.id} td.amount",
            text: humanized_money_with_symbol(ba2_new_amount))
      end

      it "total balance" do
        expect(subject).
          to have_css("#sidebar",
            text: humanized_money_with_symbol(new_total))
      end
    end
