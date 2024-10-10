shared_examples_for "has flow" do
  context "right values according to created transactions" do
    let(:transactions) { correct_items }

    def calc_amount(type)
      rub = Money.new(0, 'RUB')
      usd = Money.new(0, 'USD')
      transactions.map do |transaction|
        rub += transaction.amount if transaction.currency == 'RUB' && transaction.send(type)
        usd += transaction.amount if transaction.currency == 'USD' && transaction.send(type)
      end
      sum = usd + rub
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
