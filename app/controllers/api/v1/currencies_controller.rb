# frozen_string_literal: true

module Api::V1
  class CurrenciesController < BaseOrganizationController
    api :GET, '/currencies', 'Return all available currencies'
    def index
      render json: Dictionaries.currencies
    end
  end
end
