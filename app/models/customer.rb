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
  has_many :transactions, dependent: :destroy, inverse_of: :customer

  validate :organization, presence: true
  validate :name, presence: true
  validates :name, uniqueness: { scope: :organization_id }
end
