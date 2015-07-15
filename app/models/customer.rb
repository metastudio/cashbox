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
  has_many :transactions, dependent: :destroy, inverse_of: :customer

  validates :name, presence: true
  validates :organization, presence: true
  validates :name, uniqueness: { scope: :organization_id }

  def to_s
    name.truncate(30)
  end
end
