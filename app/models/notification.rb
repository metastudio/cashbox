class Notification < ApplicationRecord
  extend Enumerize

  belongs_to :notificator, polymorphic: true

  validates :notificator, :kind, :date, presence: true

  enumerize :kind, in: [
    :send_invitation_to_organization,
    :resend_invitation_to_organization,
    :send_invitation_global,
    :resend_invitation_global
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
    when 'send_invitation_global'
      send_invitation_global
    when 'resend_invitation_global'
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

  private

  def self.allowed?(email)
    unsubscribe = Unsubscribe.find_or_create_by(email: email)
    not unsubscribe.active?
  end

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
