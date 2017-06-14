class ApplicationTagsController < ApplicationController
	def index
		@applications = ApplicationTag.all
		if params[:method]
			@method = params[:method]
		else
			@method = "primary_tests"
		end
	end

  def create
    @app_tag = ApplicationTag.new(application_tag_params)
    if @app_tag.save
      render json: @app_tag.as_json(only: [:name, :id])
    else
      render json: @app_tag.errors, status: :unprocessable_entity
    end
  end

  def show
    @app = ApplicationTag.find(params[:id])
    @method = params[:method]
  end

  def update
    @app_tag = ApplicationTag.find(params[:id])
    if @app_tag.update(application_tag_params)
      render json: @app_tag.as_json(only: [:name, :id])
    else
      render json: @app_tag.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @app_tag = ApplicationTag.find(params[:id])
    @app_tag.destroy
    head :no_content
  end

  def application_tag_params
    params.require(:application_tag).permit(:name)
  end

  def edit
    @applications = ApplicationTag.all
  end
end
