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

  context 'colorize invoice' do
    let!(:overdue_invoice) { create :invoice, organization: org, ends_at: Date.current - 16.days }
    let!(:paid_invoice) { create :invoice, organization: org, paid_at: Date.current }

    before do
      visit invoices_path
    end

    it "overdue invoice has class 'overdue'" do
      within '#invoice_list' do
        expect(subject).to have_css("tr.invoice.overdue##{dom_id(overdue_invoice)}")
      end
    end

    it "paid invoice has class 'paid'" do
      within '#invoice_list' do
        expect(subject).to have_css("tr.invoice.paid##{dom_id(paid_invoice)}")
      end
    end
  end
end
