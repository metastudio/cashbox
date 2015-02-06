require 'spec_helper'

describe 'Transactions list' do
  include MoneyRails::ActionViewExtension

  let!(:user) { create :user, :with_organizations }
  let(:org1) { user.organizations.first }
  let(:org2) { user.organizations.last }
  let(:ba_org1) { create :bank_account, organization: org1 }
  let(:ba_org2) { create :bank_account, organization: org2 }
  let!(:categories_org1) { create_list :category, 5, organization: org1}
  let!(:categories_org2) { create_list :category, 5, organization: org2}

  before do
    sign_in user
    visit categories_path
  end

  def table_content(subject, categories)
    categories.each do |category|
      within "tbody" do
        expect(subject).to have_selector('td', text: category.name)
        expect(subject).to have_selector('td', text: category.name)
        expect(subject).to have_selector('td', text: 'Edit')
        expect(subject).to have_selector('td', text: 'Destroy')
      end
    end
  end

  subject { page }

  it "has create category btn" do
    expect(subject).to have_link('New categories')
  end

  context "default for first organization" do
    it "shows table with appropriate content" do
      table_content(subject, categories_org1)
    end
  end

  context "switch to another org" do
    before do
      within "#switch_organization" do
        click_on user.organizations.last.name
      end
      visit categories_path
    end

    it "shows table with appropriate content" do
      table_content(subject, categories_org2)
    end
  end
end
