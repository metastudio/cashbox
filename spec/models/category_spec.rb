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
    it { is_expected.to validate_presence_of(:type) }
    it { is_expected.to validate_presence_of(:name) }
    it do
      is_expected.to validate_inclusion_of(:type).in_array(%w[Income Expense])
        .with_message('shoulda-matchers test string is not a valid category type')
    end

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
