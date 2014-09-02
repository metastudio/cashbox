class Role < ActiveRecord::Base
  ROLE_NAMES = %w(owner admin user)
  belongs_to :user, inverse_of: :roles
  belongs_to :organization, inverse_of: :roles

  validates :name, inclusion: { in: ROLE_NAMES }
  validates :user, presence: true
  validates :organization, presence: true

  def owner?
    name == 'owner'
  end

  def admin?
    name == 'admin'
  end

  def user?
    name == 'user'
  end

end
