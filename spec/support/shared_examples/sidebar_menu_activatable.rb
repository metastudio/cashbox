shared_examples_for "activatable" do |activated|
  it 'is actived now' do
    expect(page).to have_css('.active', activated)
  end
end
