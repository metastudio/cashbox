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
    it { is_expected.to belong_to(:organization) }
    it { is_expected.to have_many(:transactions).dependent(:destroy) }
  end

  context 'validations' do
    it { is_expected.to validate_presence_of(:organization) }
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name).scoped_to(:organization_id)}
  end
end
