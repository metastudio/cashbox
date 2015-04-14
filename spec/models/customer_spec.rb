# == Schema Information
#
# Table name: customers
#
#  id              :integer          not null, primary key
#  name            :string(255)      not null
#  organization_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#  deleted_at      :datetime
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
    it { expect(subject).to validate_uniqueness_of(:name).scoped_to(:organization_id, :deleted_at)}
  end

  context 'when restoring' do
    let(:org)       { create :organization }
    let!(:customer) { create :customer, organization: org, name: 'Customer' }
    let!(:deleted_customer) { create :customer, organization: org, name: 'Customer',
      deleted_at: Time.now }

    it 'raise error when record exists with same organization and name' do
      expect{ deleted_customer.restore! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
