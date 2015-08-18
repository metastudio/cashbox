RSpec.shared_examples "outcome transaction" do
  describe "attributes" do
    it { expect(out.amount_cents).to eq (transfer.amount_cents + transfer.comission_cents) * (-1) }
    it { expect(out.comment).to eq (transfer.comment.to_s +
      "\nComission: " + transfer.comission.to_s) +
      (transfer.currency_mismatch? ? "\nRate: " + transfer.exchange_rate.to_s : '') }
    it { expect(out.bank_account_id).to eq transfer.bank_account_id }
    it { expect(out.category_id).to eq Category.find_by(
      Category::CATEGORY_BANK_EXPENSE_PARAMS).id}
  end
end
