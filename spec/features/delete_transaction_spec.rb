require 'rails_helper'

describe 'delete transaction', js: true do
  let!(:user)         { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:account)      { create :bank_account, organization: organization}

  before do
    sign_in user
  end

  subject{ page }

  context 'within pagination' do
    include_context 'transactions pagination'
    let!(:transactions) { create_list :transaction, transactions_count, bank_account: account }
    let(:first_transaction) { transactions.last }
    let(:last_transaction)  { transactions.first }

    before do
      visit root_path
    end

    context 'first page' do
      before do
        page.has_css?("#transaction_#{first_transaction.id} .comment")
        find("#transaction_#{first_transaction.id} .comment").click
        page.has_css?('simple_form edit_transaction')
      end

      it 'shows delete form on row click' do
        expect(subject).to have_link('Remove', href: transaction_path(first_transaction))
      end
    end

    context 'last page' do
      before do
        click_on 'Last'
        page.has_css?("#transaction_#{last_transaction.id} .comment")
        find("#transaction_#{last_transaction.id} .comment").click
        page.has_css?('simple_form edit_transaction')
      end

      it 'shows delete form on row click' do
        expect(subject).to have_link("Remove", href: transaction_path(last_transaction))
      end
    end
  end

  context 'deleting' do
    def delete_transaction
      visit root_path
      find("#transaction_#{transaction.id} .comment").click
      page.has_css?('simple_form edit_transaction')
      click_on 'Remove'
    end

    context 'when transactions count > 1' do
      let!(:transactions) { create_list :transaction, 2, bank_account: account }
      let(:transaction)   { transactions.last }

      before do
        delete_transaction
      end

      it 'removes transaction from list' do
        expect(subject).to_not have_css("#transaction_#{transaction.id}")
      end
    end
  end
end
