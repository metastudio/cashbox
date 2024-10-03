shared_examples_for "has flow" do
  context "right values according to created transactions" do
    let(:transactions) { correct_items }

    def calc_amount(type)
      sum = Money.empty
      transactions.map do |transaction|
        sum += transaction.amount if transaction.send(type)
      end
      sum
    end

    def income
      calc_amount('income?')
    end

    def expense
      calc_amount('expense?')
    end

    it 'for income' do
      within '#flow' do
        expect(page).to have_content(money_with_symbol(income))
      end
    end

    it 'for expense' do
      within '#flow' do
        expect(page).to have_content(money_with_symbol(expense))
      end
    end

    it 'for total' do
      within '#flow' do
        expect(page).to have_content(money_with_symbol(income + expense))
      end
    end
  end
end
