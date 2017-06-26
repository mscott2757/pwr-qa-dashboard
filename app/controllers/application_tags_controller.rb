class ApplicationTagsController < ApplicationController
	before_action :set_columns
	skip_before_action :disable_rotate, only: [:index]

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
		@method = "primary_tests"
		@applications = ApplicationTag.relevant_apps(@method, @env_tag)
	end

	def indirect
		@method = "tests"
		@applications = ApplicationTag.relevant_apps(@method, @env_tag)

		respond_to do |format|
			format.html { render template: "application_tags/index" }
		end
	end

  def create
    @app_tag = ApplicationTag.new(app_params)
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
    if @app_tag.update(app_params)
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

  def app_params
    params.require(:application_tag).permit(:name, :threshold)
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
