require 'rails_helper'

describe 'Delete invoice', js: true do
  let(:user)          { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:customer)     { create :customer, organization: organization }
  let!(:invoice)      { create :invoice, organization: organization, customer: customer }

  before do
    sign_in user
    visit invoice_path(invoice)
  end

  context 'Delete invoice' do
    before do
      click_on 'Destroy'
    end

    it 'has congradulation and has not invoice html element' do
      expect(page).to have_content 'Invoice was successfully deleted'
      expect(page).to_not have_css("##{dom_id(invoice)}")
    end
  end
end
