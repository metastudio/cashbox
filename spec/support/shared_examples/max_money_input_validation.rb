shared_examples_for "has money ceiling" do |field|
  context "when less max" do
    let!(:amount) { max - 1 }
    it 'is valid' do
      expect(model).to be_valid
    end
  end

  context "when equals max" do
    let!(:amount) { max }
    it 'is valid' do
      expect(model).to be_valid
    end
  end

  context "when exceeds max" do
    let!(:amount) { max + 1 }
    it 'is invalid' do
      expect(model).to be_invalid
      expect(model.errors_on(field)).
        to include("must be less than or equal to #{max}")
    end
  end
end
