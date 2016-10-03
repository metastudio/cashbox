# == Schema Information
#
# Table name: notifications
#
#  id               :integer          not null, primary key
#  sended           :boolean          default(FALSE)
#  date             :datetime
#  kind             :string
#  notificator_type :string
#  notificator_id   :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Notification < ApplicationRecord
  extend Enumerize

  belongs_to :notificator, polymorphic: true

  validates :notificator, :kind, :date, presence: true

  enumerize :kind, in: [
    :send_invitation_to_organization,
    :resend_invitation_to_organization,
    :send_invitation,
    :resend_invitation
  ]

  scope :todays, -> {
    where("date < ?", DateTime.now)
    .where(sended: false)
  }

  def deliver
    case kind
    when 'send_invitation_to_organization'
      send_invitation_to_organization
    when 'resend_invitation_to_organization'
      resend_invitation_to_organization
    when 'send_invitation'
      send_invitation_global
    when 'resend_invitation'
      resend_invitation_global
    end
    update_attributes(sended: true)
  end

  def self.deliver_all
    todays.each { |n| n.deliver }
  end

  def self.create_if_allowed(options)
    if allowed?(options[:email])
      create(options.except(:email))
    end
  end

  def self.allowed?(email)
    unsubscribe = Unsubscribe.find_or_create_by(email: email)
    not unsubscribe.active?
  end

  private

  def send_invitation_to_organization
    InvitationMailer.new_invitation_to_organization(notificator).deliver_now
  end

  def resend_invitation_to_organization
    InvitationMailer.resend_invitation_to_organization(notificator).deliver_now
  end

  def send_invitation_global
    InvitationMailer.new_invitation_global(notificator).deliver_now
  end

  def resend_invitation_global
    InvitationMailer.resend_invitation_global(notificator).deliver_now
  end
end
