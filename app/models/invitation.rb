class Invitation < ActiveRecord::Base
  belongs_to :member

  after_create :send_invitation

  validates :member, presence: true
  validates :role, presence: true
  validates :email, presence: true

  private

  def send_invitation
    InvitationMailer.new_invitation(self).deliver
  end
end
