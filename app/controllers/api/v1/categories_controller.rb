module Api::V1
  class CategoriesController < ApiController

    api :GET, '/organizations/:organization_id/categories', 'Return categories for current organization'
    def index
      @categories = current_organization.categories.ordered
    end

    api :GET, '/organizations/:organization_id/categories/for_select', 'Return categories for current organization with select format'
    def for_select
      @categories = current_organization.categories.ordered
    end

  end
end
