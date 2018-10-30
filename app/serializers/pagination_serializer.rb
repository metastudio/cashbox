# frozen_string_literal: true

class PaginationSerializer
  attr_reader :pagination

  def initialize(pagination)
    @pagination = pagination
  end

  def as_json(_opts)
    {
      current:  pagination.current,
      next:     pagination.next,
      previous: pagination.previous,
    }
  end
end
