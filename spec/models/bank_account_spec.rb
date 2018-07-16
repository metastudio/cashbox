# == Schema Information
#
# Table name: bank_accounts
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  description     :string(255)
#  balance_cents   :integer          default(0), not null
#  currency        :string(255)      default("USD"), not null
#  organization_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#  deleted_at      :datetime
#  visible         :boolean          default(TRUE)
#  position        :integer
#  invoice_details :text
#

require 'rails_helper'

describe BankAccount do
  context 'association' do
    it { expect(subject).to belong_to(:organization) }
    it { expect(subject).to have_many(:transactions).dependent(:destroy) }
    it { expect(subject).to have_many(:invoices).dependent(:destroy) }
  end

  context 'validation' do
    it { expect(subject).to validate_presence_of(:name) }
    it { expect(subject).to validate_presence_of(:currency) }
    # issue of this test https://github.com/thoughtbot/shoulda-matchers/issues/958
    skip { expect(subject).to validate_inclusion_of(:currency).in_array(%w(USD RUB)) }
    it { expect(["USD","RUB"]).to include(subject.currency) }

    context 'custom' do
      it_behaves_like 'has money ceiling', 'balance' do
        let!(:model) { build :bank_account, balance: amount }
      end

      describe 'when residue negative' do
        let(:bank_account) { build :bank_account, residue: -500 }
        it 'is invalid' do
          expect(bank_account).to be_invalid
        end
      end
    end
  end

  describe 'soft delete' do
    let(:bank_account)  { create :bank_account }
    let!(:transaction)  { create :transaction, bank_account: bank_account,
      amount: Money.new(100, bank_account.currency) }

    describe 'bank_account destroy-restore' do
      before do
        bank_account.destroy
      end

      it 'doesnt change balance' do
        expect{ bank_account.restore }.to_not change{bank_account.balance}
      end
    end
  end
end
