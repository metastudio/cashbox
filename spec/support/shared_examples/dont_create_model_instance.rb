shared_examples_for "don't create model instance" do |model|
  it 'doesnt change count' do
    expect{ subject }.to_not change{ model.count }
  end
end
