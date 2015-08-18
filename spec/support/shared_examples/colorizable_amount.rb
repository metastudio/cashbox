shared_examples_for 'colorizable amount' do |within_css, negative|
  if negative
    context 'when negative' do
      let(:amount) { -1 }
      within within_css do
        expect(page).to have_css('.negative-text')
      end
    end
  end
end
