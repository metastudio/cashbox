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

class Customer < ActiveRecord::Base
  acts_as_paranoid

  belongs_to :organization, inverse_of: :customers
  has_many :transactions, dependent: :destroy, inverse_of: :customer

  validates :name, presence: true
  validates :organization, presence: true
  validates :name, uniqueness: { scope: [:organization_id , :deleted_at] }

  # gem 'paranoia' doesn't run validations on restore
  before_restore :name_uniqueness

  def to_s
    name.truncate(30)
  end

  private
    def name_uniqueness
      errors.add(:name, 'has been taken', strict: true) if Customer.find_by(
        name: name, organization_id: organization_id)
    end
end
