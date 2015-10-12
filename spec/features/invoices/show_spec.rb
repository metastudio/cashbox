require 'spec_helper'

describe 'Invoice show page' do
  include MoneyHelper

  let(:user) { create :user }
  let(:org)  { create :organization, with_user: user }
  let!(:org_ba) { create :bank_account, organization: org, currency: 'RUB' }

  before do
    sign_in user
  end

  subject{ page }

  context 'Download as PDF' do
    let!(:invoice) { create :invoice, :with_items, number: '1234567812345678', organization: org }

    context 'with usual download mode' do
      before do
        visit invoice_path(invoice)
        click_on 'Download as PDF'
      end

      it 'has correct response headers' do
        expect(page.response_headers['Content-Type']).to eq 'application/pdf'
        expect(page.response_headers['Content-Disposition']).to \
          include(invoice.pdf_filename + '.pdf')
        expect(page.response_headers['Content-Length']).to_not eq 0 || nil
      end
    end

    context 'with debug mode' do
      before do
        visit invoice_path(invoice, format: :pdf, debug: true)
      end

      it 'show Invoice details' do
        expect(subject).to have_content('Invoice')
        expect(subject).to have_content(I18n.l(invoice.ends_at))
        expect(subject).to have_content(money_with_symbol(invoice.amount))
        expect(subject).to have_content(invoice.invoice_items.last.customer.to_s)
        expect(subject).to have_content(invoice.customer.invoice_details)
        expect(subject).to have_content(org_ba.invoice_details)
        expect(subject).to have_content("Invoice ##{invoice.number}")
      end
    end
  end
end
