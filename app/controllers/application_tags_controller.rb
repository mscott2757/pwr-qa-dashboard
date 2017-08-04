# controller for applications
class ApplicationTagsController < ApplicationController
	before_action :set_app_columns, only: [:index, :indirect, :refresh]
  before_action :set_options, only: [:show, :edit_app_col, :edit_test_col, :refresh]
  before_action :set_tests, only: [:show, :edit_test_col]
	skip_before_action :disable_rotate, only: [:index]

  def set_app_columns
    session[:app_col] = 2 if !session.include?(:app_col)
    @app_col = session[:app_col].to_i
  end

  def set_options
    @options = AppOptions.new(params[:method], @env_tag)
  end

  def set_tests
    @app = ApplicationTag.find(params[:id])
    @tests = @options.show_tests_by_env(@app)
  end

	def index
    @options = AppOptions.new("primary_tests", @env_tag)
		session[:rotate] = true
    # @culprits = ApplicationTag.possible_culprits(@env_tag)
    @applications = @options.relevant_apps
	end

	def indirect
    @options = AppOptions.new("tests", @env_tag)
    @applications = @options.relevant_apps

		respond_to do |format|
			format.html { render template: "application_tags/index" }
		end
	end

  def create
    @app_tag = ApplicationTag.new(app_params)
    if @app_tag.save
			flash[:info] = "Successfully added #{ @app_tag.name }"
      render json: @app_tag.edit_as_json
    else
      render json: @app_tag.errors, status: :unprocessable_entity
    end
  end

  def show
    session[:test_col] = 4 if !session.include?(:test_col)
    @test_col = session[:test_col].to_i
  end

  def update
    @app = ApplicationTag.find(params[:id])
    if @app.update(app_params)
			flash[:info] = "#{ @app.name } successfully updated"
      render json: @app.edit_as_json
    else
      render json: @app.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @app = ApplicationTag.find(params[:id])
    @app.destroy
		flash[:info] = "Successfully deleted #{ @app.name }"
    head :no_content
  end

  def app_params
    params.require(:application_tag).permit(:name, :threshold, :group)
  end

  def edit
    @applications = ApplicationTag.edit_all_as_json
  end

  def refresh
    @applications = @options.relevant_apps

    respond_to do |format|
      format.js
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def edit_app_col
    session[:app_col] = params[:app_col]
    @app_col = params[:app_col].to_i
    @applications = @options.relevant_apps

    respond_to do |format|
      format.js
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def edit_test_col
    session[:test_col] = params[:test_col]
    @test_col = params[:test_col].to_i

    respond_to do |format|
      format.js
      format.html { redirect_back(fallback_location: root_path) }
    end
  end
end
