require 'spec_helper'

describe 'Update invoice', js: true do
  include MoneyHelper

  let(:user)          { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:customer1)    { create :customer, organization: organization }
  let!(:customer2)    { create :customer, organization: organization }
  let!(:invoice)      { create :invoice, organization: organization, customer: customer1 }
  let!(:invoice_with_items) { create :invoice, :with_items, organization: organization }
  let(:new_amount)    { Money.new(1000, invoice.currency) }

  before do
    sign_in user
    visit invoices_path
  end

  context 'Update invoice without invoice items' do
    before do
      within "##{dom_id(invoice)}" do
        click_on 'Edit'
      end
      page.execute_script("$(\"##{dom_id(invoice, :edit)} #invoice_amount\").val('');")
      select2 customer2.name, css: '#s2id_invoice_customer_name', search: true
      fill_in 'invoice[amount]', with: new_amount
      click_on 'Update Invoice'
    end

    it { expect(page).to have_content 'Invoice was successfully updated' }
    it { expect(page).to have_content(money_with_symbol(Money.new(new_amount, invoice.currency))) }
    it { expect(page).to have_content customer2.name }
  end

  context 'Update invoice with invoice items' do
    let(:new_item_amount) { Money.new(1000, invoice_with_items.currency) }

    before do
      within "##{dom_id(invoice_with_items)}" do
        click_on 'Edit'
      end
      page.execute_script("$('#invoice .nested-fields:first input.nested-amount').val('');")
      first('#invoice .nested-fields input.nested-amount').set(new_item_amount)
      click_on 'Update Invoice'
    end

    it 'invoice updated with items' do
      expect(page).to have_content 'Invoice was successfully updated'
      expect(page).to have_css('td',
        text: money_with_symbol(Money.new(new_item_amount, invoice.currency)))
    end

    context 'invoice amount must be disabled then invoice has items' do
      before do
        click_on 'Edit'
      end

      it { expect(page).to have_css('#invoice_amount:disabled') }
      it 'amount must be enabled after delete all items' do
        page.all('a', text: 'delete').each(&:click)
        expect(page).to_not have_css('#invoice_amount:disabled')
        expect(page).to have_css('#invoice_amount')
      end
    end
  end
end
