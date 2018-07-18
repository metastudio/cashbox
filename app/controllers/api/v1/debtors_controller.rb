# frozen_string_literal: true

module Api::V1
  class DebtorsController < BaseOrganizationController
    def index
      render json: DebtorsPresenter.new(current_organization).present
    end
  end
end
