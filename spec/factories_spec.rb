require 'rails_helper'

describe 'validate FactoryBot factories' do
  FactoryBot.factories.each do |factory|
    context "with factory for :#{factory.name}" do
      subject { FactoryBot.build(factory.name) }

      xit "is valid" do
        expect(subject).to be_valid, subject.errors.full_messages.join(',')
      end
    end
  end
end
