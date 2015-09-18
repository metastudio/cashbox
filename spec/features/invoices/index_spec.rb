require 'spec_helper'

describe 'invoices index page' do
  let(:user) { create :user }
  let(:org)  { create :organization, with_user: user }

  before do
    sign_in user
  end

  subject{ page }

  include_context 'invoices pagination'
  it_behaves_like 'paginateable' do
    let!(:list)      { create_list :invoice, invoices_count, organization: org }
    let(:list_class) { '.invoices' }
    let(:list_page)  { invoices_path }
  end

  context "show only current organization's invoices" do
    let(:org1) { create :organization, with_user: user }
    let(:org2) { create :organization, with_user: user }
    let!(:org1_invoice) { create :invoice, organization: org1 }
    let!(:org2_invoice) { create :invoice, organization: org2 }

    before do
      visit invoices_path
    end

    it "invoice index page displays current organization's invoices" do
      expect(subject).to have_content(org1_invoice.customer)
    end

    it "invoice index page doesn't display another invoices" do
      expect(subject).to_not have_content(org2_invoice.customer)
    end
  end

  context 'complete invoice', js: true do
    let!(:account)  { create :bank_account, organization: org }
    let!(:category) { create :category, :income, organization: org }
    let!(:invoice)  { create :invoice, organization: org, amount: 500 }
    let(:comission) { Money.new(100, invoice.currency) }

    before do
      visit invoices_path
      click_on 'Complete Invoice'
      within '#new_transaction' do
        select category.name, from: 'transaction[category_id]'
        select account.name, from: 'transaction[bank_account_id]'
        fill_in 'transaction[comission]', with: comission
        fill_in 'transaction[comment]', with: 'TestComment'
      end
      click_on 'Create'
      visit invoices_path
    end

    it 'invoice paid_at must present' do
      expect(subject).to have_content(invoice.paid_at)
    end

    context 'create transaction by invoice' do
      before do
        visit root_path
      end

      it 'transaction must present' do
        expect(subject).to have_content(money_with_symbol(invoice.amount - comission))
        expect(subject).to have_content(category.name)
        expect(subject).to have_content(account.name)
        expect(subject).to have_content('TestComment')
        expect(subject).to have_content(I18n.l(Date.current))
      end
    end
  end
end
