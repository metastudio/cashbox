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

    it "create account by deffault" do
      expect(page).to have_content("New organization bank account")
      click_on "Create default Bank account"
      expect(BankAccount.all.count).to eq(1)
      expect(BankAccount.first.organization.name).to eq(organization_name)
    end

    it "create account manually" do
      expect(page).to have_content("New organization bank account")
      click_on "Create manually"
      expect(page).to have_css("form#new_bank_account")
      within("form#new_bank_account") do
        fill_in 'bank_account[name]', with: "New bank account"
        click_on 'Create Bank account'
      end
      expect(page).to have_content("Bank account was created successfully")
      click_on "Next step"
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
      click_on "Create manually"
      expect(page).to have_css("form#new_category")
      within("form#new_category") do
        fill_in 'category[name]', with: "New category"
        click_on 'Create Category'
      end
      expect(page).to have_content("Category was created successfully!")
      click_on "Finish"
      expect(page).to have_content("**Congratulations**")
    end
  end
end
