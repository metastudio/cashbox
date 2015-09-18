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
    let!(:invoice) { create :invoice, organization: org }

    context 'Download' do
      before do
        visit invoice_path(invoice)
        click_on 'Download as PDF'
      end

      it { expect(page.response_headers['Content-Type']).to eq 'application/pdf' }
      it { expect(page.response_headers['Content-Disposition']).to \
        include("#{invoice.customer.to_s}_#{invoice.ends_at.month}_#{invoice.ends_at.year}.pdf") }
      it { expect(page.response_headers['Content-Length']).to_not eq 0 || nil }
    end

    context 'Content' do
      before do
        visit invoice_path(invoice, format: :pdf, debug: true)
      end

      it 'PDF content' do
        expect(subject).to have_css('h1.uppercase', text: 'INVOICE')
        expect(subject).to have_css('strong.uppercase', text: 'DATE')
        expect(subject).to have_content(I18n.l(invoice.ends_at))
        expect(subject).to have_content(invoice.currency)
        expect(subject).to have_content('Bank account for wire transfers:')
        expect(subject).to have_content(money_with_symbol(invoice.amount))
      end
    end
  end
end
