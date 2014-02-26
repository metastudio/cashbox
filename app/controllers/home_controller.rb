class HomeController < ApplicationController
  before_filter :require_organization
end
