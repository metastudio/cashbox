require 'rails_helper'

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
  end

  context 'Update invoice without invoice items' do
    before do
      visit invoice_path(invoice)
      click_on 'Edit'

      page.execute_script("$(\"##{dom_id(invoice, :edit)} #invoice_amount\").val('');")
      select2 customer2.name, css: '#s2id_invoice_customer_name', search: true
      fill_in 'invoice[amount]', with: new_amount
      click_on 'Update Invoice'
    end

    it 'has congratulation, amount and ciustomer name' do
      expect(page).to have_content 'Invoice was successfully updated'
      expect(page).to have_content(money_with_symbol(Money.new(new_amount, invoice.currency)))
      expect(page).to have_content customer2.name
    end
  end

  context 'Update invoice with invoice items' do
    let(:new_item_amount) { Money.new(1000, invoice_with_items.currency) }

    before do
      visit invoice_path(invoice_with_items)
      click_on 'Edit'

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
        visit invoice_path(invoice_with_items)
        click_on 'Edit'
      end

      it 'amount must be enabled after delete all items' do
        expect(page).to have_css('#invoice_amount:disabled')
        page.all('a', text: 'delete').each(&:click)
        expect(page).to_not have_css('#invoice_amount:disabled')
        expect(page).to have_css('#invoice_amount')
      end
    end
  end
end
