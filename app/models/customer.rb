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

class Customer < ActiveRecord::Base
  belongs_to :organization, inverse_of: :customers
  has_many :transactions, inverse_of: :customer
end
