shared_examples_for "filterable object" do
  def to_css_id(item)
    "#transaction_#{item.id}"
  end

  it "shows correct items" do
    correct_items.each do |correct_item|
      expect(page).to have_selector(to_css_id(correct_item))
    end
  end

  it "doesn't show filtered items" do
    wrong_items.each do |wrong_item|
      expect(page).to_not have_selector(to_css_id(wrong_item))
    end
  end
end
