require 'rails_helper'

describe "create organization" do
  let(:user) { create :user }
  let(:organization_name) { generate :organization_name }

  before :each do
    sign_in user
  end

  context "first step" do
    before { create_organization(organization_name) }

    it "create organization" do
      expect(page).to have_content("Organization was successfully created.")
    end
  end

  context "second step", js: true do
    before { create_organization(organization_name) }

    it "create account by default" do
      expect(page).to have_content("New organization bank account")
      click_on "Create default Bank account"
      expect(BankAccount.all.count).to eq(1)
      expect(BankAccount.first.organization.name).to eq(organization_name)
    end

    it "create account manually" do
      expect(page).to have_content("New organization bank account")
      click_on "Create it manually"
      fill_in 'Name', with: "New bank account"
      click_on 'Create bank accounts'
      expect(page).to have_content("Bank accounts was created successfully")
      expect(BankAccount.all.count).to eq(1)
      expect(BankAccount.last.organization.name).to eq(organization_name)
      expect(page).to have_content("New organization categories")
    end
  end

  context "third step", js: true do
    before do
      create_organization(organization_name)
      click_on "Create default Bank account"
    end

    it "create categories by default" do
      expect(page).to have_content("New organization categories")
      click_on "Create default Categories"
      expect(Category.all.count).to eq(5)
    end

    it "create category manually" do
      expect(page).to have_content("New organization categories")
      click_on "Create it manually"
      fill_in 'Name', with: "New category"
      click_on 'Create categories'
      expect(page).to have_content("Categories was created successfully")
      expect(Category.all.count).to eq(3)
      expect(page).to have_content("**Congratulations**")
    end
  end

  context 'then second step complete' do
    before do
      create_organization(organization_name)
      click_on "Create default Bank account"
      visit new_account_organization_path
    end

    it 'redirect to categories path' do
      expect(current_path).to eq(new_category_organization_path)
    end
  end

  context 'then third step complete' do
    before do
      create_organization(organization_name)
      click_on "Create default Bank account"
      click_on "Create default Categories"
      visit new_account_organization_path
    end

    it 'redirect to home' do
      expect(current_path).to eq(root_path)
    end
  end
end
