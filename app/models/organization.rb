class Organization < ActiveRecord::Base
  belongs_to :owner, class_name: 'User', inverse_of: :own_organizations

  validates :name, presence: true
  validates :owner, presence: true
end
