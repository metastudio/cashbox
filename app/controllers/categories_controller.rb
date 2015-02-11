class CategoriesController < ApplicationController
  before_action :set_category, only: [:edit, :update, :destroy, :show]
  before_action :require_organization

  def index
    @categories = current_organization.categories.page(params[:page]).per(10)
  end

  def new
    @category = current_organization.categories.build
  end

  def edit
  end

  def create
    @category = current_organization.categories.build(category_params)

    if @category.save
      redirect_to categories_path, notice: 'Category was successfully created.'
    else
      render action: 'new'
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

  def show
    @q = if @category.system?
      current_organization.transactions.where(category_id: @category.id).ransack(params[:q])
    else
      @category.transactions.ransack(params[:q])
    end
    @transactions = @q.result.page(params[:page])
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_category
      @category = Category.for_organization(current_organizaiton).find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def category_params
      params.require(:category).permit(:name, :type)
    end
end
