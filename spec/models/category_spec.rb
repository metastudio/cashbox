# == Schema Information
#
# Table name: categories
#
#  id              :integer          not null, primary key
#  type            :string(255)      not null
#  name            :string(255)      not null
#  organization_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#  system          :boolean          default(FALSE)
#  deleted_at      :datetime
#

  # == Schema Information
#
# Table name: categories
#
#  id              :integer          not null, primary key
#  type            :string(255)      not null
#  name            :string(255)      not null
#  organization_id :integer
#  created_at      :datetime
#  updated_at      :datetime
#  system          :boolean          default(FALSE)
#  deleted_at      :datetime
#

require 'rails_helper'

describe Category do
  context "association" do
    it { is_expected.to belong_to(:organization).optional }
    it { is_expected.to have_many(:transactions).dependent(:destroy) }
  end

  context "validation" do
    let(:category) { Category.new(type: type_value) }

    context 'when type is valid' do
      shared_examples 'valid type' do |valid_type|
        let(:type_value) { valid_type }
  
        it 'no errors message' do
          category.valid?
          expect(category.errors[:type]).to be_empty
        end
      end

      it_behaves_like 'valid type', 'Income'
      it_behaves_like 'valid type', 'Expense'
    end

    context 'when type is invalid' do
      let(:type_value) { 'InvalidType' }
  
      it 'errors message' do
        category.valid?
        expect(category.errors[:type]).to include('InvalidType is not a valid category type')
      end
    end

    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:name) }

    context "if system" do
      before { subject.system = true }
      it { is_expected.to_not validate_presence_of(:organization_id) }
    end

    context "if not system" do
      before { subject.system = false }
      it { is_expected.to validate_presence_of(:organization_id) }
    end
  end
end
