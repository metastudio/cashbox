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
end
