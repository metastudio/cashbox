include MoneyHelper

RSpec.shared_examples "income transaction" do
  describe 'attributes' do
    it { expect(inc.amount_cents).to eq amount }
    it { expect(inc.comment).to eq (transfer.comment.to_s +
      "\nComission: " + money_with_symbol(transfer.comission)) +
      (transfer.currency_mismatch? ? "\nRate: " + transfer.exchange_rate.to_s : '') }
    it { expect(inc.bank_account_id).to eq transfer.reference_id }
    it { expect(inc.category_id).to eq Category.find_by(
      Category::CATEGORY_BANK_INCOME_PARAMS).id }
  end
end
