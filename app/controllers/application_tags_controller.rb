class ApplicationTagsController < ApplicationController
	def index
		@applications = ApplicationTag.all
		if params[:indirect_apps]
			# indirect apps
			@method = "tests"

		else
			# primary apps
			@method = "primary_tests"
		end
	end

  def create
    @app_tag = ApplicationTag.create(application_tag_params)
    render json: @app_tag.as_json(only: [:name, :id])
  end

  def application_tag_params
    params.require(:application_tag).permit(:name)
  end
end
