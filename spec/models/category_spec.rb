require 'spec_helper'

describe Category do
  context "association" do
    it { should belong_to(:organization) }
    it { should have_many(:transactions).dependent(:restrict_with_exception) }
  end

  context "validation" do
    it { should validate_presence_of(:type) }
    it { should validate_presence_of(:name) }
    it { should ensure_inclusion_of(:type).in_array(%w[Income Expense]) }

    context "if system" do
      before { subject.stub(:system?) { true } }
      it { should_not validate_presence_of(:organization_id) }
    end

    context "if not system" do
      before { subject.stub(:system?) { false } }
      it { should validate_presence_of(:organization_id) }
    end
  end
end
