require 'spec_helper'

describe 'customers page' do
  let(:user) { create :user, :with_organizations }
  let(:org1) { user.organizations.first }
  let(:org2) { user.organizations.last }
  let!(:org1_customer) { create :customer, organization: org1 }
  let!(:org2_customer) { create :customer, organization: org2 }
  let!(:org1_deleted_customer) { create :customer, deleted_at: Time.current }

  before do
    sign_in user
    visit customers_path
  end

  after { Capybara.reset_sessions! }

  subject{ page }

  it "customer index page displays current organization's customers" do
    expect(subject).to have_content(org1_customer.name)
    expect(subject).to have_content(org1_customer.invoice_details)
  end

  it "customer index page doesn't display another customers" do
    expect(subject).to_not have_content(org2_customer.name)
  end

  it "customer index page doesn't display deleted customers" do
    expect(subject).to_not have_content(org1_deleted_customer.name)
  end
end
