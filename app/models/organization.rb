class Organization < ActiveRecord::Base
  belongs_to :owner, class_name: 'User', inverse_of: :own_organizations
  has_many :user_organizations, inverse_of: :organization, dependent: :destroy
  has_many :users, through: :user_organizations

  validates :name, presence: true
  validates :owner, presence: true
end
