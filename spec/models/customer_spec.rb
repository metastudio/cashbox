# == Schema Information
#
# Table name: customers
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  organization_id :integer
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
    it { expect(subject).to validate_uniqueness_of(:organization_id).scoped_to(:name)}
  end
end
