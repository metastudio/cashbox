shared_examples_for "sortable object" do |sort_by, field|
  let!(:transaction)  { Timecop.travel(3.day.ago) { create :transaction,
    :with_customer, bank_account: ba, amount: 100, comment: 'Comment' }}
  let!(:transaction2) { Timecop.travel(2.day.ago) { create :transaction,
    :with_customer, bank_account: ba, amount: 200, comment: 'Comment2' }}
  let!(:transaction3) { Timecop.travel(1.day.ago) { create :transaction,
    :with_customer, bank_account: ba, amount: 300, comment: 'Comment3' }}
  let!(:transaction4) { create :transaction, :with_customer, bank_account: ba,
    amount: 600, comment: 'Comment4' }
  let(:correct_order) { [transaction, transaction2, transaction3, transaction4] }

  # for correct alphabetical sort ( otherwise specs will fail occasionally )
  def assign_associations(field)
    if field == :category
      transaction.update_attribute(:category_id, cat.id)
      transaction2.update_attribute(:category_id, cat2.id)
      transaction3.update_attribute(:category_id, cat3.id)
      transaction4.update_attribute(:category_id, cat4.id)
    end

    if field == :customer
      transaction.update_attribute(:customer_id, cust.id)
      transaction2.update_attribute(:customer_id, cust2.id)
      transaction3.update_attribute(:customer_id, cust3.id)
      transaction4.update_attribute(:customer_id, cust4.id)
    end
  end

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
      assign_associations(field)
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
