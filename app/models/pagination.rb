# frozen_string_literal: true

class Pagination
  attr_accessor :current, :next, :previous

  def initialize(pages = {})
    pages = pages.with_indifferent_access

    @current  = pages[:current]
    @next     = pages[:next]
    @previous = pages[:previous]
  end
end
