class ApplicationTagsController < ApplicationController
	before_action :set_columns

  def set_columns
    if !session.include?(:app_col)
      session[:app_col] = 2
    end

    @app_col = session[:app_col].to_i

    if !session.include?(:test_col)
      session[:test_col] = 4
    end

    @test_col = session[:test_col].to_i
  end

	def index
		if params[:method]
			@method = params[:method]
		else
			@method = "primary_tests"
		end

		@applications = ApplicationTag.relevant_apps(@method, @env_tag)
	end

  def create
    @app_tag = ApplicationTag.new(application_tag_params)
    if @app_tag.save
			flash[:info] = "Successfully added app"
      render json: @app_tag.edit_as_json
    else
      render json: @app_tag.errors, status: :unprocessable_entity
    end
  end

  def show
    @app = ApplicationTag.find(params[:id])
    @method = params[:method]
    @jira_ticket = JiraTicket.new
    @tests = @app.tests_by_env(@method, @env_tag)
  end

  def update
    @app_tag = ApplicationTag.find(params[:id])
    if @app_tag.update(application_tag_params)
			flash[:info] = "Application successfully updated"
      render json: @app_tag.edit_as_json
    else
      render json: @app_tag.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @app_tag = ApplicationTag.find(params[:id])
    @app_tag.destroy
		flash[:info] = "Application successfully deleted"
    head :no_content
  end

  def application_tag_params
    params.require(:application_tag).permit(:name)
  end

  def edit
    @applications = ApplicationTag.edit_all_as_json
  end

  def edit_app_col
    session[:app_col] = params[:app_col]
    redirect_back(fallback_location: root_path)
  end

  def edit_test_col
    session[:test_col] = params[:test_col]
    redirect_back(fallback_location: root_path)
  end
end
