# frozen_string_literal: true

module RequestHelpers
  module JsonHelpers
    def json_body
      RecursiveOpenStruct.new(JSON.parse(response.body), recurse_over_arrays: true, preserve_original_keys: true)
    end
  end
end

RSpec.configure do |config|
  config.include RequestHelpers::JsonHelpers, type: :request
end
