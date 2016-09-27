class CategoriesController < ApplicationController
  layout 'settings'
  before_action :set_category, only: [:edit, :update, :destroy]
  before_action :require_organization
  before_action :redirect_for_not_ready_organization

  def index
    @categories = current_organization.categories.ordered.page(params[:page]).per(10)
  end

  def new
    @category = current_organization.categories.build
    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
  end

  def create
    @category = current_organization.categories.build(category_params)
    if @category.save
      respond_to do |format|
        format.js
        format.html do
          redirect_to categories_path, notice: 'Category was
            successfully created.'
        end
      end
    else
      respond_to do |format|
        format.js { render :new }
        format.html { render action: 'new' }
      end
    end
  end

  def update
    if @category.update(category_params)
      redirect_to categories_path, notice: 'Category was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @category.destroy
    redirect_to categories_path
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.for_organization(current_organization).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:name, :type)
    end
end
