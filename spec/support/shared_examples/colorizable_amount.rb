shared_examples_for 'colorizable amount' do |within_css, negative|
  context 'when positive' do
    let(:amount) { 1 }
    it 'has relevant css' do
      within within_css do
        expect(page).to have_css('.positive')
      end
    end
  end

  context 'when zero' do
    let(:amount) { 0 }
    it 'has relevant css' do
      within within_css do
        expect(page).to have_css('.empty')
      end
    end
  end

  if negative
    context 'when negative' do
      let(:amount) { -1 }
      within within_css do
        expect(page).to have_css('.negative')
      end
    end
  end
end
