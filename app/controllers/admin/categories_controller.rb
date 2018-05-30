class Admin::CategoriesController < ApplicationController

    def index
      @categories = Category.all
    end

    def show
      @category = Category.find_by_friendly_id!(params[:id])
    end

    def new
      @category = Category.new
    end

    def create
      @category = Category.new(category_params)

      if @category.save
        redirect_to admin_categeries_path
      else
        render "new"
      end
    end

    def edit
      @category = Category.find_by_friendly_id!(params[:id])
    end

    def update
      @category = Category.find_by_friendly_id!(params[:id])

      if @category.update(category_params)
        redirect_to admin_categories_path
      else
        render "edit"
      end
    end

    def destroy
      @category = Category.find_by_friendly_id!(params[:id])
      @category.destroy

      redirect_to admin_categories_path
    end

    protected

    def category_params
      params.require(:category).permit(:name, :description, :friendly_id, :status, :category_id)
    end
end
