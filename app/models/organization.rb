# == Schema Information
#
# Table name: organizations
#
#  id         :integer          not null, primary key
#  name       :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

class Organization < ActiveRecord::Base
  has_many :owners,
    -> { where members: { role: "owner" } }, through: :members,
    source: :user, inverse_of: :own_organizations
  has_many :members, inverse_of: :organization, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :users, through: :members
  has_many :bank_accounts, dependent: :destroy, inverse_of: :organization
  has_many :transactions, through: :bank_accounts, inverse_of: :organization

  validates :name, presence: true

  def total_rub
    bank_accounts.total_balance("RUB")
  end

  def total_usd
    bank_accounts.total_balance("USD")
  end
end
