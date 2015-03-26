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

  acts_as_paranoid

  belongs_to :organization, inverse_of: :customers
  has_many :transactions, inverse_of: :customer

  validate :name, presence: true

  def to_s
    name.truncate(30)
  end
end
