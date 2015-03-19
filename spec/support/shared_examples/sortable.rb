shared_examples_for "sortable object" do |sort_by, field|
  let!(:transaction)  { Timecop.travel(3.day.ago) { create :transaction,
    bank_account: ba, amount: 100, comment: 'Comment',  category: cat  }}
  let!(:transaction2) { Timecop.travel(2.day.ago) { create :transaction,
    bank_account: ba, amount: 200, comment: 'Comment2', category: cat2 }}
  let!(:transaction3) { Timecop.travel(1.day.ago) { create :transaction,
    bank_account: ba, amount: 300, comment: 'Comment3', category: cat3 }}
  let!(:transaction4) { create :transaction, bank_account: ba, amount: 600,
    comment: 'Comment4', category: cat4 }
  let(:correct_order) { [transaction, transaction2, transaction3, transaction4] }

  def to_view(elem, field)
    case field
    when :amount
      money_with_symbol(elem.send(field))
    when :bank_account
      elem.send(field).name
    when :category
      elem.send(field).name
    when :created_at
      I18n.l elem.send(field)
    else
      elem.send(field)
    end
  end

  context "first sort" do
    before do
      visit root_path
      within "thead" do
        click_on sort_by
      end
    end

    it "shows correct order" do
      correct_order.each_with_index do |elem, i|
        expect(page).to have_selector("tbody tr:nth-child(#{i + 1})",
          text: to_view(elem, field))
      end
    end

    context "second sort" do
      before do
        within "thead" do
          click_on sort_by
        end
      end

      it "shows correct order" do
        correct_order.reverse.each_with_index do |elem, i|
          expect(page).to have_selector("tbody tr:nth-child(#{i + 1})",
            text: to_view(elem, field))
        end
      end
    end
  end
end
