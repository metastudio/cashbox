require 'spec_helper'

describe 'invoices show page', js: true do
  include MoneyHelper

  let(:user) { create :user }
  let(:org)  { create :organization, with_user: user }

  before do
    sign_in user
  end

  subject{ page }

  context 'Download as PDF' do
    let!(:invoice) { create :invoice, :with_items, organization: org }

    context 'with usual download mode' do
      before do
        visit invoice_path(invoice)
        click_on 'Download as PDF'
      end

      it { expect(page.response_headers['Content-Type']).to eq 'application/pdf' }
      it { expect(page.response_headers['Content-Disposition']).to \
        include(invoice.pdf_filename + '.pdf') }
      it { expect(page.response_headers['Content-Length']).to_not eq 0 || nil }
    end

    context 'with debug mode' do
      before do
        visit invoice_path(invoice, format: :pdf, debug: true)
      end

      it 'show Invoice details' do
        expect(subject).to have_content('INVOICE')
        expect(subject).to have_content(I18n.l(invoice.ends_at))
        expect(subject).to have_content(money_with_symbol(invoice.amount))
        expect(subject).to have_content(invoice.invoice_items.last.description)
      end
    end
  end
end
