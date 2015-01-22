require 'spec_helper'

describe 'Transactions list' do
  include MoneyRails::ActionViewExtension

  let(:user) { create :user, :with_organizations }
  let(:org1) { user.organizations.first }
  let(:org2) { user.organizations.last }
  let(:org1_ba) { create :bank_account, organization: org1 }
  let(:org2_ba) { create :bank_account, organization: org2 }
  let!(:org1_transaction) { create :transaction, bank_account: org1_ba, amount: 100 }
  let!(:org2_transaction) { create :transaction, bank_account: org2_ba, amount: 500 }

  before do
    sign_in user
  end

  subject { page }

  it "root page displays current organization's transactions" do
    expect(subject).to have_content(humanized_money_with_symbol(org1_transaction.amount))
  end

  it "root page doesn't display another transactions" do
    expect(subject).to_not have_content(humanized_money_with_symbol(org2_transaction.amount))
  end

  context 'when switch organization' do
    before do
      within "#switch_organization" do
        click_on org2.name
      end
    end

    it "displays right transactions" do
      expect(subject).to have_content(humanized_money_with_symbol(org2_transaction.amount))
    end

    it "doesn't display another organization transactions" do
      expect(subject).to_not have_content(humanized_money_with_symbol(org1_transaction.amount))
    end
  end

  context "pagination" do
    let(:transactions) { [] }
    before do
      transactions = FactoryGirl.create_list :transaction, 15, bank_account: org1_ba
      visit root_path
    end

    it "lists 10 first transactions" do
      within ".transactions" do
        transactions.first(10).each do |transaction|
          expect(subject).to have_selector('td', text: humanized_money_with_symbol(transaction.amount))
        end
      end
    end

    it "doesnt list after 10  transactions" do
      within ".transactions" do
        transactions.last(5).each do |transaction|
          expect(subject).to_not have_selector('td', text: humanized_money_with_symbol(transaction.amount))
        end
      end
    end

    context "switch to second page" do
      before do
        within '.pagination' do
          click_on '2'
        end
      end

      it "doesnt list 10 first transactions" do
        within ".transactions" do
          transactions.first(10).each do |transaction|
            expect(subject).to_not have_selector('td', text: humanized_money_with_symbol(transaction.amount))
          end
        end
      end

      it "lists 5 last transactions" do
        within ".transactions" do
          transactions.last(5).each do |transaction|
            expect(subject).to have_selector('td', text: humanized_money_with_symbol(transaction.amount))
          end
        end
      end
    end
  end
end
