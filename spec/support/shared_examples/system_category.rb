RSpec.shared_examples "system category" do |type|
  describe 'page' do
    before do
      within '.transactions' do
        click_on type
      end
    end

    it "shows transaction" do
      expect(subject).to have_css("#transaction_#{right_transaction.id}")
    end

    it "doesn't show another organizations' transactions" do
      expect(subject).to_not have_css("#transaction_#{wrong_transaction.id}")
    end
  end
end
