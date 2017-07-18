class ApplicationTagsController < ApplicationController
	before_action :set_app_columns, only: [:index, :indirect, :refresh]
  before_action :set_test_columns, only: [:show]
  before_action :set_method, only: [:show, :edit_app_col, :edit_test_col, :refresh]
  before_action :set_tests, only: [:show, :edit_test_col]
	skip_before_action :disable_rotate, only: [:index]

  def set_app_columns
    session[:app_col] = 2 if !session.include?(:app_col)
    @app_col = session[:app_col].to_i
  end

  def set_test_columns
    session[:test_col] = 4 if !session.include?(:test_col)
    @test_col = session[:test_col].to_i
  end

  def set_method
    @method = params[:method]
  end

  def set_tests
    @app = ApplicationTag.find(params[:id])
    @tests = @app.tests_by_env(@method, @env_tag)
  end

	def index
		@method = "primary_tests"
		session[:rotate] = true
    @culprits = ApplicationTag.possible_culprits(@env_tag)
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
			flash[:info] = "Successfully added #{ @app_tag.name }"
      render json: @app_tag.edit_as_json
    else
      render json: @app_tag.errors, status: :unprocessable_entity
    end
  end

  def show
  end

  def update
    @app_tag = ApplicationTag.find(params[:id])
    if @app_tag.update(app_params)
			flash[:info] = "#{ @app_tag.name } successfully updated"
      render json: @app_tag.edit_as_json
    else
      render json: @app_tag.errors, status: :unprocessable_entity
    end
  end

  def destroy
    @app_tag = ApplicationTag.find(params[:id])
    @app_tag.destroy
		flash[:info] = "Successfully deleted #{ @app_tag.name }"
    head :no_content
  end

  def app_params
    params.require(:application_tag).permit(:name, :threshold)
  end

  def edit
    @applications = ApplicationTag.edit_all_as_json
  end

  def refresh
		@applications = ApplicationTag.relevant_apps(@method, @env_tag)

    respond_to do |format|
      format.js
      format.html { redirect_back(fallback_location: root_path) }
    end
  end

  def edit_app_col
    session[:app_col] = params[:app_col]
    @app_col = params[:app_col].to_i
		@applications = ApplicationTag.relevant_apps(@method, @env_tag)

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
