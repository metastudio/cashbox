require 'spec_helper'

describe 'invoices page' do
  let(:user) { create :user, :with_organizations }
  let(:org1) { user.organizations.first }
  let(:org2) { user.organizations.last }
  let!(:org1_invoice) { create :invoice, organization: org1 }
  let!(:org2_invoice) { create :invoice, organization: org2 }

  before do
    sign_in user
    visit invoices_path
  end

  subject{ page }

  it "invoice index page displays current organization's invoices" do
    expect(subject).to have_content(org1_invoice.customer)
  end

  it "invoice index page doesn't display another invoices" do
    expect(subject).to_not have_content(org2_invoice.customer)
  end
end
