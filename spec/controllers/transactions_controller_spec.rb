require 'spec_helper'

describe TransactionsController, type: :controller do
  include Devise::TestHelpers
  let!(:user) { create :user }
  let!(:org)  { create :organization, with_user: user }
  let!(:org2) { create :organization, with_user: user }
  let!(:ba)   { create :bank_account, organization: org }
  let!(:ba2)  { create :bank_account, organization: org2 }
  let!(:cat)  { create :category, organization: org }
  let!(:cat2) { create :category, organization: org2 }

  before do
    sign_in user
  end

  describe 'POST #create' do
    context 'when bank from not current organization' do
      subject { post :create, format: :js,
        transaction: { amount: 100, category_id: cat.id, bank_account: ba2.id } }
      it_behaves_like "don't create model instance", Transaction
    end

    context 'when category from not current organization' do
      subject { post :create, format: :js,
        transaction: { amount: 100, category_id: cat2.id, bank_account: ba.id } }
      it_behaves_like "don't create model instance", Transaction
    end

    context 'when category and bank from not current organization' do
      subject { post :create, format: :js,
        transaction: { amount: 100, category_id: cat2.id, bank_account: ba2.id } }
      it_behaves_like "don't create model instance", Transaction
    end

  end

  describe 'create_transfer' do
    let!(:ba3) { create :bank_account, organization: org }
    context 'when bank-from from not current organization' do
      subject { post :create_transfer, format: :js,
        transfer: { amount: 100, bank_account: ba2.id, reference_id: ba.id } }
      it_behaves_like "don't create model instance", Transaction
    end

    context 'when bank-to from not current organization' do
      subject { post :create_transfer, format: :js,
        transfer: { amount: 100, bank_account: ba.id, reference_id: ba2.id } }
      it_behaves_like "don't create model instance", Transaction
    end
  end
end
