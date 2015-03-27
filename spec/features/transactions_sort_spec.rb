require 'spec_helper'

describe 'Transactions sort' do
  include MoneyHelper

  let(:user) { create :user }
  let(:org)  { create :organization, with_user: user }
  let(:ba)   { create :bank_account, organization: org }
  let(:cat)  { create :category, organization: org, name: 'cat'  }
  let(:cat2) { create :category, organization: org, name: 'cat2' }
  let(:cat3) { create :category, organization: org, name: 'cat3' }
  let(:cat4) { create :category, organization: org, name: 'cat4' }

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
    it_behaves_like 'sortable object', 'Date', :created_at
  end

  context "by category" do
    it_behaves_like 'sortable object', 'Category', :category
  end

  context 'by customer' do
    it_behaves_like 'sortable object', 'Customer', :customer
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
