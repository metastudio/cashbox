# == Schema Information
#
# Table name: customers
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  organization_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#

require 'spec_helper'

describe Customer do
  context 'association' do
    it { expect(subject).to belong_to(:organization) }
    it { expect(subject).to have_many(:transactions).dependent(:destroy) }
  end

  context 'validations' do
    subject { create :customer }
    it { expect(subject).to validate_presence_of(:organization) }
    it { expect(subject).to validate_presence_of(:name) }
    it { expect(subject).to validate_uniqueness_of(:name).scoped_to(:organization_id)}
  end
end
