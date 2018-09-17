# frozen_string_literal: true

require 'rails_helper'
require 'transfer'

describe Transfer do
  subject { Transfer.new }

  context 'validation' do
    it { should validate_presence_of(:amount) }
    it { should validate_presence_of(:bank_account_id) }
    it { should validate_length_of(:comment).is_at_most(255) }
    it { should validate_presence_of(:reference_id) }
    it { should validate_numericality_of(:comission).is_greater_than_or_equal_to(0) }
    it { should validate_length_of(:comission).is_at_most(10) }
    it { should validate_presence_of(:reference_id) }
    it { should validate_numericality_of(:amount).is_less_than_or_equal_to(Dictionaries.money_max) }

    context 'custom validations' do
      subject { transfer }

      context 'when has commission' do
        let(:from) { create :bank_account }
        let(:to)   { create :bank_account }
        let(:transfer) { build :transfer, bank_account_id: from.id, reference_id: to.id, amount: 100, comission: 200 }

        it 'is invalid' do
          expect(subject).to be_invalid
          expect(subject.errors_on(:comission)).to include("Can't be more than amount")
        end
      end

      context 'when depends on bank account' do
        let(:transfer) { build :transfer, bank_account_id: from.id, reference_id: to.id }

        describe 'balance overflow' do
          let(:from) { create :bank_account, balance: 10_000 }
          let(:to)   { create :bank_account, :full }

          before do
            transfer.save
          end

          it 'is invalid' do
            expect(transfer.save).to eq false
          end

          it 'has error on amount' do
            expect(transfer.errors.messages[:amount]).to include('Balance overflow')
          end
        end

        context 'transfer_account' do
          let(:from) { create :bank_account, balance: 100 }
          let(:to)   { from }

          it 'is invalid' do
            expect(subject).to be_invalid
            expect(subject.errors_on(:reference_id)).to include("Can't transfer to same account")
          end
        end

        context 'diff currency' do
          let(:from) { create :bank_account, currency: 'USD', balance: 9_999_999 }
          let(:to)   { create :bank_account, currency: 'RUB', balance: 9_999_999 }

          describe 'exchange_rate' do
            let(:transfer) do
              build :transfer, exchange_rate: 10_001,
                bank_account_id: from.id, reference_id: to.id,
                from_currency: from.currency, to_currency: to.currency
            end

            it 'is invalid' do
              expect(subject).to be_invalid
              expect(subject.errors_on(:exchange_rate)).to include('must be less than 10000')
            end
          end
        end

        context 'when has commission' do
          let(:from) { create :bank_account }
          let(:to)   { create :bank_account }
          let(:transfer) { build :transfer, bank_account_id: from.id, reference_id: to.id, amount: 0, comission: 0 }

          it 'is invalid' do
            expect(subject).to be_invalid
            expect(subject.errors_on(:amount)).to include('must be other than 0')
          end
        end
      end
    end
  end

  describe '#save' do
    let(:transfer) { build :transfer }

    subject { transfer.save }

    context 'with valid data' do
      context 'create 2 transactions' do
        it { expect{ subject }.to change{ Transaction.count }.by(2) }

        describe 'attributes' do
          let(:inc) { transfer.inc_transaction }
          let(:out) { transfer.out_transaction }

          before do
            transfer.save
          end

          describe 'same currency' do
            let(:amount) { transfer.amount_cents }

            it_behaves_like 'income transaction'
            it_behaves_like 'outcome transaction'
          end

          describe 'with different currencies' do
            let(:transfer) { build :transfer, :with_different_currencies, exchange_rate: 2, amount: 111 }

            it_behaves_like 'income transaction' do
              let(:amount) { transfer.exchange_rate * transfer.amount_cents }
            end
            it_behaves_like 'outcome transaction' do
              let(:amount) { transfer.amount_cents }
            end
          end
        end
      end
    end

    context 'with invalid data' do
      let(:from) { create :bank_account, balance: 2000 }
      let(:to)   { create :bank_account, balance: Dictionaries.money_max }
      let(:transfer) { build :transfer, bank_account_id: from.id, reference_id: to.id }

      context "doesn't create transactions" do
        # TODO: 1 of 2 transactions is created
        it { expect{ subject }.to change{ Transaction.count }.by(0) }
        # before do
        #   transfer.save
        # end

        # it { expect(transfer.errors.messages[:amount]).to include('Balance overflow') }
      end
    end
  end

  describe '#send_notification' do
    ActiveJob::Base.queue_adapter = :test
    before { ActiveJob::Base.queue_adapter.enqueued_jobs = [] }
    let!(:account) { create :bank_account }
    let!(:transfer) { create :transfer, bank_account_id: account.id }

    it 'send notification after creation' do
      expect(NotificationJob).to have_been_enqueued.with(
        account.organization.name,
        'Transfer was created',
        "Transfer was created in #{account.name} bank account"
      )
    end
  end
end
