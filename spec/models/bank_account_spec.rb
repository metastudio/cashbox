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
#

require 'spec_helper'

describe BankAccount do
  context "association" do
    it { should belong_to(:organization) }
    it { should have_many(:transactions).dependent(:destroy)}
  end

  context "validation" do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:currency) }
    it { should ensure_inclusion_of(:currency).in_array(%w(USD RUB)) }

    context 'custom' do
      it_behaves_like 'has money ceiling', 'balance' do
        let!(:model) { build :bank_account, balance: amount }
      end
    end
  end

  describe "soft delete" do
    let(:bank_account)  { create :bank_account }
    let(:amount)        { Money.new(100, bank_account.currency) }
    let!(:transaction)  { create :transaction, bank_account: bank_account,
      amount: amount }

    describe "bank_account destroy" do
      it "doesn't change balance on destroy" do
        expect{bank_account.destroy}.to_not change{bank_account.balance}.by(amount)
      end
    end

    describe "bank_account restore" do
      before do
        bank_account.destroy
      end

      it "doesn't change balance on restore" do
        expect{bank_account.restore}.to_not change{bank_account.balance}.by(amount)
      end
    end
  end
end
