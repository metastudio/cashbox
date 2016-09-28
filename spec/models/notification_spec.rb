require 'rails_helper'

RSpec.describe Notification, type: :model do
  after(:each) do
    ActionMailer::Base.deliveries.clear
  end

  context 'association' do
    it { should belong_to(:notificator) }
  end

  context 'validation' do
    it { should validate_presence_of(:notificator) }
    it { should validate_presence_of(:kind) }
    it { should validate_presence_of(:date) }
  end

  context "#todays" do
    let!(:notification) { create :notification }
    let!(:tomorow_notification) { create :notification, date: 1.day.from_now }

    subject { Notification.todays }

    it 'contain notification' do
      expect(subject).to include(notification)
    end

    it 'not contain tomorow_notification' do
      expect(subject).not_to include(tomorow_notification)
    end
  end

  context '#deliver' do
    let!(:notification) { create :notification }

    it 'be sended' do
      notification.deliver
      expect(notification.sended).to eq(true)
      expect(ActionMailer::Base.deliveries.count).to eq(1)
    end
  end

  context '#deliver_all' do
    let!(:notification) { create :notification }
    let!(:yesterday_notification) { create :notification, date: 1.day.ago }

    it 'deliver all notifications' do
      expect(Notification.todays.count).to eq(2)
      Notification.deliver_all
      expect(Notification.todays.count).to eq(0)
      expect(Notification.where(sended: true).count).to eq(2)
      expect(ActionMailer::Base.deliveries.count).to eq(2)
    end
  end
end
