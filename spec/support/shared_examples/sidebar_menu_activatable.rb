shared_examples_for "activatable" do |activated|
  it 'is actived now' do
    within '.list-group' do
      expect(page).to have_css('.active', text: activated)
    end
  end
end
