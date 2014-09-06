class Invitation < ActiveRecord::Base
  belongs_to :user
  belongs_to :organization

  after_create :send_invitation

  validates :user, presence: true
  validates :organization, presence: true

  private

  def send_invitation
    InvitationMailer.new_invitation(self).deliver
  end
end
