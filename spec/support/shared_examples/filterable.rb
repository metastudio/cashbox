shared_examples_for "filterable object" do
  def to_css_id(item)
    "#transaction_#{item.id}"
  end

  def expect_currencies(rub, usd)
    selector = rub > 0 ? '.bg-success' : '.bg-danger'
    rub = money_with_symbol rub
    selector = usd > 0 ? '.bg-success' : '.bg-danger'
    usd = money_with_symbol usd

    expect(page).to have_selector(selector, rub)
    expect(page).to have_selector(selector, usd)
  end

  it "shows correct items" do
    correct_items.each do |correct_item|
      expect(page).to have_selector(to_css_id(correct_item))
    end
  end

  it "shows total amount for correct_items" do
    rub, usd = Money.new(0, "RUB"), Money.new(0, "USD")
    correct_items.each do |correct_item|
      rub += correct_item.amount if correct_item.currency == 'RUB'
      usd += correct_item.amount if correct_item.currency == 'USD'
    end

    expect_currencies(rub, usd)
  end

  it "shows total income for correct_items" do
    rub, usd = Money.new(0, "RUB"), Money.new(0, "USD")
    correct_items.each do |correct_item|
      rub += correct_item.amount if correct_item.currency == 'RUB' && correct_item.income?
      usd += correct_item.amount if correct_item.currency == 'USD' && correct_item.income?
    end

    expect_currencies(rub, usd)
  end

  it "shows total expense for correct_items" do
    rub, usd = Money.new(0, "RUB"), Money.new(0, "USD")
    correct_items.each do |correct_item|
      rub += correct_item.amount if correct_item.currency == 'RUB' && correct_item.expense?
      usd += correct_item.amount if correct_item.currency == 'USD' && correct_item.expense?
    end

    expect_currencies(rub, usd)
  end

  it "doesn't show filtered items" do
    wrong_items.each do |wrong_item|
      expect(page).to_not have_selector(to_css_id(wrong_item))
    end
  end
end
