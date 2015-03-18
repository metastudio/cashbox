shared_examples_for "has flow" do
  context "right values according to created transactions" do
    let(:transactions) { correct_items | wrong_items }

    def calc_amount(type)
      sum = 0
      transactions.each do |transaction|
        sum += transaction if transaction.send(type)
      end
    end

    def income
      money_with_symbol(calc_amount('income?'))
    end

    def expense
      money_with_symbol(calc_amount('expense?'))
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
