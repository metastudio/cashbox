require 'spec_helper'

describe 'create transfer transaction', js: true do
  let!(:user)         { create :user }
  let!(:organization) { create :organization, with_user: user }
  let!(:ba1)          { create :bank_account, organization: organization,
    balance: 50000 }
  let!(:ba2)          { create :bank_account, organization: organization,
    balance: 99999 }

  let(:ba1_name)      { ba1.name }
  let(:ba2_name)      { ba2.name }

  let(:amount)        { 123.23 }
  let(:comment)       { "Test transaction" }
  let(:comission)     { 0.25 }

  let(:transactions)  { organization.transactions.where(
    bank_account_id: [ba1.id, ba2.id]) }

  def create_transfer
    visit root_path
    click_on 'Transaction'
    click_on 'Transfer'
    within '#new_transfer_form' do
      fill_in 'transfer[amount]', with: amount
      select ba1.name, from: 'transfer[bank_account_id]' if ba1_name.present?
      select ba2.name, from: 'transfer[reference_id]' if ba2_name.present?
      fill_in 'transfer[comission]', with: comission
      fill_in 'transfer[comment]',   with: comment
      click_on 'Create'
    end
    page.has_content?(/(Please review the problems below)|(#{amount})/) # wait after page rerender
  end

  subject{ create_transfer; page }

  before :each do
    sign_in user
  end

  context "with valid data" do
    it "creates two new transactions" do
      expect{ subject }.to change{ transactions.count }.by(2)
    end

    it "shows created transactions in transactions list" do
      create_transfer
      within ".transactions" do
        expect(page).to have_content(amount)
        expect(page).to have_content(amount + comission)
      end
    end

    it "appends comission to the comment" do
      create_transfer
      within ".transactions" do
        expect(page).to have_content(comment + "\nComission: " + comission.to_s)
      end
    end

    context "when outcome transfer" do
      it "creates transaction with negative amount" do
        expect{ subject }.
          to change{ transactions.where(amount_cents: (amount + comission) * -  100).count }.by(1)
      end
    end

    context "when income transfer" do
      it "creates transaction with positive amount" do
        expect{ subject }.
          to change{ transactions.where(amount_cents: amount * 100).count }.by(1)
      end
    end
  end

  context "without comment" do
    let(:comment) { nil }

    it "create transactions without errors" do
      expect{ subject }.to change{ transactions.count }.by(2)
    end
  end

  context "with not selected FROM" do
    let(:ba1_name) { nil }

    it "doesn't create transactions" do
      expect{ subject }.to_not change{ transactions.count }
    end

    it "shows error for FROM field" do
      expect(subject).to have_inline_error("can't be blank").for_field_name('transfer[bank_account_id]')
    end
  end

  context "with not selected TO" do
    let(:ba2_name) { nil }

    it "doesn't create transactions" do
      expect{ subject }.to_not change{ transactions.count }
    end

    it "shows error for TO field" do
      expect(subject).to have_inline_error("can't be blank").for_field_name('transfer[reference_id]')
    end
  end

  context "transfer to different currency", js: true do
    let!(:ba2) { create :bank_account, organization: organization, currency: "USD",
      balance: 99999 }
    let!(:ba3) { create :bank_account, organization: organization, currency: "USD",
      balance: 99999 }

    before do
      visit root_path
      click_on 'Transaction'
      click_on 'Transfer'
    end

    subject{ page }

    context "when nothing selected" do
      it "doesn't show exchange rate" do
        expect(page).to_not have_field("transfer[exchange_rate]")
      end
    end

    context "when select banks with same currency" do
      before do
        within '#new_transfer_form' do
          select ba2.name, from: 'transfer[bank_account_id]'
          select ba3.name, from: 'transfer[reference_id]'
        end
      end

      it "doesn't show exchange rate" do
        within '#new_transfer_form' do
          expect(page).to_not have_field("transfer[exchange_rate]")
        end
      end
    end

    context "when select banks with different currency" do
      before do
        within '#new_transfer_form' do
          select ba1.name, from: 'transfer[bank_account_id]'
          select ba2.name, from: 'transfer[reference_id]'
        end
      end

      it "show exchange rate" do
        within '#new_transfer_form' do
          expect(page).to have_field("transfer[exchange_rate]")
        end
      end

      context "and select same currency" do
        before do
          within '#new_transfer_form' do
            select ba2.name, from: 'transfer[bank_account_id]'
            select ba3.name, from: 'transfer[reference_id]'
          end
        end

        it "doesn't show exchange rate" do
          within '#new_transfer_form' do
            expect(page).to_not have_field("transfer[exchange_rate]")
          end
        end
      end
    end
  end
end
