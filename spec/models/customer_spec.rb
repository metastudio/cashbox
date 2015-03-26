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
  context "association" do
    it { should belong_to(:organization) }
    it { should have_many(:transactions) }
  end
end
