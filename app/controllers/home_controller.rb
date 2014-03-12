class HomeController < ApplicationController
  before_filter :require_organization

  def show
  end
end
