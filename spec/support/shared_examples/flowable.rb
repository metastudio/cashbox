shared_examples_for "has flow" do
  context "right income" do
    it 'is valid' do
      expect(model).to be_valid
    end
  end

end
