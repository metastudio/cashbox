def start_headless
  # based on http://stackoverflow.com/questions/15823177/continuous-integration-running-parallel-tests-suites-that-require-xvfb
  if (!$headless_started)
    # allow display autopick (by default)
    # allow each headless to destroy_at_exit (by default)
    # allow each process to have their own headless by setting reuse: false
    headless_server = Headless.new(:reuse => false)
    headless_server.start

    $headless_started = true
    puts "Process[#{Process.pid}] started headless server display: #{headless_server.display}"
  end
end

RSpec.configure do |config|
  config.before(:each, js: true) do
    start_headless
  end
end
