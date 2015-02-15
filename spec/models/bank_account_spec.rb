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
      it_behaves_like "has money ceiling", 'balance' do
        let(:max)    { Transaction::AMOUNT_MAX }
        let!(:model) { build :bank_account, balance: amount }
      end
    end
  end
end
