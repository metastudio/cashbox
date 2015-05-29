require 'spec_helper'

describe 'delete transaction', js: true do
  let!(:user)         { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:account)      { create :bank_account, organization: organization}

  before do
    sign_in user
  end

  subject{ page }

  context "within pagination" do
    include_context 'transactions pagination'
    let!(:transactions) { create_list :transaction, transactions_count,
      bank_account: account }
    let(:first_transaction) { transactions.last }
    let(:last_transaction)  { transactions.first }

    before do
      visit root_path
    end

    context "first page" do
      before do
        find("#transaction_#{first_transaction.id} .comment").click
        page.has_css?('simple_form edit_transaction')
      end

      it "shows delete form on row click" do
        expect(subject).to have_link("Remove", href: transaction_path(first_transaction))
      end
    end

    context "last page" do
      before do
        click_on 'Last'
        find("#transaction_#{last_transaction.id} .comment").click
        page.has_css?('simple_form edit_transaction')
      end

      it "shows delete form on row click" do
        expect(subject).to have_link("Remove", href: transaction_path(last_transaction))
      end
    end
  end

  context "deleting" do
    let!(:transaction)   { create :transaction, bank_account: account }

    context 'when no filters' do
      before do
        visit root_path
      end

      it_behaves_like "js table row deletable", "This is default page, you will"
    end

    context 'when matching filter applied' do
      before do
        visit root_path
        select account.to_s, from: 'q[bank_account_id_eq]'
        click_on 'Search'
      end

      it_behaves_like "js table row deletable", "There is nothing found"
    end
  end
end
