require 'spec_helper'

RSpec.describe NotificationJob, type: :job do
  let(:org_name) { 'Organization' }
  it "matches with enqueued job" do
    ActiveJob::Base.queue_adapter = :test
    expect do
      NotificationJob.perform_later(org_name,
        "#{org_name} title", "#{org_name} body")
    end.to have_enqueued_job(NotificationJob)
  end
end
