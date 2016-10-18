module Api::V1
  class CategoriesController < ApiController
    before_action :set_category, only: [:show, :update, :destroy]

    def_param_group :category do
      param :category, Hash, required: true, action_aware: true do
        param :name, String, 'Name'
        param :type, String, 'Type'
      end
    end

    api :GET, '/organizations/:organization_id/categories', 'Return categories for current organization'
    def index
      @categories = current_organization.categories.ordered
    end

    api :GET, '/organizations/:organization_id/categories/:id', 'Return category'
    def show
    end

    api :POST, '/organizations/:organization_id/categories', 'Create category'
    param_group :category, CategoriesController
    def create
      @category = current_organization.categories.build category_params
      if @category.save
        render :show
      else
        render json: @category.errors, status: :unprocessable_entity
      end
    end

    api :PUT, '/organizations/:organization_id/categories/:id', 'Update category'
    param_group :category, CategoriesController
    def update
      if @category.update(category_params)
        render :show
      else
        render json: @category.errors, status: :unprocessable_entity
      end
    end

    api :DELETE, '/organizations/:organization_id/categories/:id', 'Destroy category'
    def destroy
      @category.destroy
      render :show # acts_as_paranoid
    end

    private

    def set_category
      @category = current_organization.categories.find(params[:id])
    end

    def category_params
      params.require(:category).permit(:name, :type)
    end
  end
end
