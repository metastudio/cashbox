# == Schema Information
#
# Table name: customers
#
#  id              :integer          not null, primary key
#  name            :string           not null
#  organization_id :integer          not null
#  created_at      :datetime
#  updated_at      :datetime
#  deleted_at      :datetime
#  invoice_details :text
#

require 'spec_helper'

describe Customer do
  context 'association' do
    it { expect(subject).to belong_to(:organization) }
    it { expect(subject).to have_many(:transactions) }
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
    let!(:deleted_customer) { create :customer, organization: org, name: 'Customer', deleted_at: Time.current }

    it 'raise error when record exists with same organization and name' do
      expect{ deleted_customer.restore! }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end

  context 'scopes' do
    context 'with_name(name)' do
      it 'should return names of customers insensitive with downcase' do
        c1 = create :customer, name: 'Bill'
        c2 = create :customer, name: 'bob'
        c3 = create :customer, name: 'John'
        expect(Customer.with_name('b')).to match_array [c1, c2]
      end

      it 'should return names of customers insensitive with uppercase' do
        c1 = create :customer, name: 'Bill'
        c2 = create :customer, name: 'bob'
        expect(Customer.with_name('B')).to match_array [c1, c2]
      end
    end
  end
end
