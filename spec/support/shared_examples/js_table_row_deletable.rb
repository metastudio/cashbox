shared_examples_for "js table row deletable" do |no_elements_msg|
  context "have proper message when no elements left" do
    def delete_transaction
      find("#transaction_#{transaction.id} .comment").click
      page.has_css?('simple_form edit_transaction')
      click_on "Remove"
    end

    before do
      delete_transaction
    end

    it "removes transaction from list" do
      expect(subject).to_not have_css("#transaction_#{transaction.id}")
    end

    context "when the only transaction" do
      it "show message no transactions" do
        expect(page).to have_content no_elements_msg
      end
    end
  end
end
