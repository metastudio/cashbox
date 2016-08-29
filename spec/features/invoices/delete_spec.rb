require 'spec_helper'

describe 'Delete invoice', js: true do
  let(:user)          { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:customer)     { create :customer, organization: organization }
  let!(:invoice)      { create :invoice, organization: organization, customer: customer }

  before do
    sign_in user
    visit invoice_path(invoice)
  end

  after { Capybara.reset_sessions! }

  context 'Delete invoice' do
    before do
      click_on 'Destroy'
    end

    it { expect(page).to have_content 'Invoice was successfully deleted' }
    it { expect(page).to_not have_css("##{dom_id(invoice)}") }
  end
end
