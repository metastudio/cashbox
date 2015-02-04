require 'spec_helper'

describe 'Transactions sort' do
  include MoneyRails::ActionViewExtension

  let(:user) { create :user, :with_organizations }
  let(:org)  { user.organizations.first }
  let(:ba)   { create :bank_account, organization: org }
  let(:ba2)  { create :bank_account, organization: org }
  let(:ba3)  { create :bank_account, organization: org }
  let(:ba4)  { create :bank_account, organization: org }

  before do
    sign_in user
  end

  subject { page }

  context "by amount" do
    it_behaves_like 'sortable object', 'Amount', :amount
  end

  context "by comment" do
    it_behaves_like 'sortable object', 'Comment', :comment
  end

  context "by date" do
    it_behaves_like 'sortable object', 'Date', :date
  end

  context "by bank_account name" do
    it_behaves_like 'sortable object', 'Account', :bank_account
  end

  context "by category" do
    it_behaves_like 'sortable object', 'Category', :category
  end

  context "filter sort" do
    let!(:transaction)  { create :transaction, bank_account: ba,
      amount: 100, comment: 'Comment' }
    let!(:transaction2) { create :transaction, bank_account: ba,
      amount: 100, comment: 'Comment2' }
    let!(:transaction3) { create :transaction, bank_account: ba,
      amount: 300, comment: 'Comment3' }
    let(:correct_order) { [transaction, transaction2] }

    context "first sort" do
      before do
        visit root_path
        fill_in 'q[amount_eq]', with: 100
        click_on 'Search'
        within "thead" do
          click_on 'Comment'
        end
      end

      it "sorts filtered" do
        correct_order.each_with_index do |elem, i|
          expect(page).to have_selector(".transactions tbody tr:nth-child(#{i + 1})",
            text: elem.comment)
        end
      end

      context "second sort" do
        before do
          within "thead" do
            click_on 'Comment'
          end
        end

        it "sorts filtered" do
          correct_order.reverse.each_with_index do |elem, i|
            expect(page).to have_selector(".transactions tbody tr:nth-child(#{i + 1})",
              text: elem.comment)
          end
        end
      end
    end
  end
end
