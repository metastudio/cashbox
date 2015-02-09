require 'rails_helper'

describe 'validate FactoryGirl factories' do
  FactoryGirl.factories.each do |factory|
    context "with factory for :#{factory.name}" do
      subject { FactoryGirl.build(factory.name) }

      it "is valid" do
        expect(subject.valid?).to be_truthy, subject.errors.full_messages.join(',')
      end
    end
  end
end
