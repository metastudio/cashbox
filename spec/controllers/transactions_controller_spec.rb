require 'rails_helper'

describe TransactionsController, type: :controller do
  include Devise::Test::ControllerHelpers
  let(:user) { create :user }
  let!(:org) { create :organization, with_user: user }
  let!(:org2){ create :organization, with_user: user }
  let(:ba)   { create :bank_account, organization: org }
  let(:ba2)  { create :bank_account, organization: org2 }
  let(:cat)  { create :category, organization: org }
  let(:cat2) { create :category, organization: org2 }

  before do
    sign_in user
  end

  describe 'POST #create' do
    context 'when params for current org' do
      subject do
        post :create, params: {
          format: :js,
          transaction: { amount: 100, category_id: cat.id, bank_account_id: ba.id }
        }
      end
      it "creates a transaction" do
        expect{ subject }.to change{ Transaction.count }
      end
    end

    context 'when bank from not current organization' do
      subject do
        post :create, params: {
          format: :js,
          transaction: { amount: 100, category_id: cat.id, bank_account_id: ba2.id }
        }
      end
      it "doesnt create Transaction" do
        expect{ subject }.to_not change{ Transaction.count }
      end
    end

    context 'when category from not current organization' do
      subject do
        post :create, params: {
          format: :js,
          transaction: { amount: 100, category_id: cat2.id, bank_account_id: ba.id }
        }
      end
      it "doesnt create Transaction" do
        expect{ subject }.to_not change{ Transaction.count }
      end
    end

    context 'when category and bank from not current organization' do
      subject do
        post :create, params: {
          format: :js,
          transaction: { amount: 100, category_id: cat2.id, bank_account_id: ba2.id }
        }
      end
      it "doesnt create Transaction" do
        expect{ subject }.to_not change{ Transaction.count }
      end
    end
  end

  describe 'create_transfer' do
    let!(:ba3) { create :bank_account, organization: org, balance: 20000 }
    context 'when params for current organization' do
      subject do
        post :create_transfer, params: {
          format: :js,
          transfer: { amount: 100, comission: 0, bank_account_id: ba3.id, reference_id: ba.id }
        }
      end
      it "creates 2 transactions" do
        expect{ subject }.to change{ Transaction.count }.by(2)
      end
    end

    context 'when bank-from from not current organization' do
      subject do
        post :create_transfer, params: {
          format: :js,
          transfer: { amount: 100, bank_account: ba2.id, reference_id: ba.id }
        }
      end
      it "doesnt create Transaction" do
        expect{ subject }.to_not change{ Transaction.count }
      end
    end

    context 'when bank-to from not current organization' do
      subject do
        post :create_transfer, params: {
          format: :js,
          transfer: { amount: 100, bank_account: ba.id, reference_id: ba2.id }
        }
      end
      it "doesnt create Transaction" do
        expect{ subject }.to_not change{ Transaction.count }
      end
    end
  end
end
