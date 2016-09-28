class Notification < ApplicationRecord
  extend Enumerize

  belongs_to :notificator, polymorphic: true

  validates :notificator, :kind, :date, presence: true

  enumerize :kind, in: [
    :resend_invitation
  ]

  scope :todays, -> {
    where("date < ?", DateTime.now)
    .where(sended: false)
  }

  def deliver
    case kind
    when 'resend_invitation'
      notificator.resend
    end
    update_attributes(sended: true)
  end

  def self.deliver_all
    todays.each { |n| n.deliver }
  end
end
