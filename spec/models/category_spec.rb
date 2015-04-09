# == Schema Information
#
# Table name: categories
#
#  id              :integer          not null, primary key
#  type            :string           not null
#  name            :string           not null
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

require 'spec_helper'

describe Category do
  context "association" do
    it { expect(subject).to belong_to(:organization) }
    it { expect(subject).to have_many(:transactions).dependent(:destroy) }
  end

  context "validation" do
    it { expect(subject).to validate_presence_of(:type) }
    it { expect(subject).to validate_presence_of(:name) }
    it { expect(subject).to validate_inclusion_of(:type).in_array(%w[Income Expense]) }

    context "if system" do
      before { subject.system = true }
      it { expect(subject).to_not validate_presence_of(:organization_id) }
    end

    context "if not system" do
      before { subject.system = false }
      it { expect(subject).to validate_presence_of(:organization_id) }
    end
  end
end
