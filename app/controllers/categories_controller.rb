class CategoriesController < ApplicationController
  before_action :set_category, only: [:edit, :update, :destroy]
  before_action :set_organization, only: [:index, :edit, :update, :new, :create, :destroy]

  def index
    @categories = Category.all
  end

  def new
    @category = @organization.categories.build
  end

  def edit
  end

  def create
    @category = @organization.categories.build(category_params)

    if @category.save
      redirect_to organization_categories_path(@organization), notice: 'Category was successfully created.'
    else
      render action: 'new'
    end
  end

  def update
    if @category.update(category_params)
      redirect_to organization_categories_path(@organization), notice: 'Category was successfully updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @category.destroy
    redirect_to organization_categories_path(@organization)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.find(params[:id])
    end

    def set_organization
      @organization = Organization.find(params[:organization_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:name, :type)
    end
end
