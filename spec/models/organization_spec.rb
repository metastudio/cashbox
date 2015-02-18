# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

require 'spec_helper'

describe Organization do
  context "assocation" do
    it { should have_many(:owners).class_name('User').through(:members) }
    it { should have_many(:members).dependent(:destroy) }
    it { should have_many(:bank_accounts).dependent(:destroy) }
    it { should have_many(:users).through(:members) }
    it { should have_many(:categories).dependent(:destroy) }
    it { should have_many(:transactions).through(:bank_accounts) }
  end

  context "validation" do
    it { should validate_presence_of(:name) }
  end
end
