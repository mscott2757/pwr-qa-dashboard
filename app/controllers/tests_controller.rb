class TestsController < ApplicationController
  before_action :set_test, only: [:update, :edit, :build]

  def set_test
    @test = Test.find(params[:id])
  end

  def index
    @tests = Test.edit_all_as_json
    @applications = ApplicationTag.all_as_json
    @environments = EnvironmentTag.all_as_json
		@types = TestType.all_as_json
  end

  def update
    tests = @test.parameterized ? Test.where(name: @test.name) : [ @test ]

    if params[:test][:modal]
      indirect_apps = params[:test][:application_tags].split(", ").map { |app_name| ApplicationTag.find_by_name(app_name) }
    else
      indirect_apps = params[:test][:application_tags] ? params[:test][:application_tags].map { |app_id| ApplicationTag.find(app_id) } : []
    end

    tests.each do |test|
      if params[:test][:primary_app] != "0"
        test.primary_app_id = params[:test][:primary_app]
      else
        test.primary_app.primary_tests.delete(test) if test.primary_app
      end

      if params[:test][:test_type] != "0"
        test.test_type_id = params[:test][:test_type]
      else
        test.test_type.tests.delete(test) if test.test_type
      end

      test.application_tags.push(*indirect_apps)
      test.application_tags.reverse.each do |app|
        test.application_tags.delete(app) if !indirect_apps.include?(app)
      end

      test.group = params[:test][:group]
      test.environment_tag_id = params[:test][:environment_tag] if !test.parameterized

      test.save
    end

    @test.reload
		flash[:info] = "Successfully updated #{ @test.name }"
    if params[:test][:modal]
      redirect_back(fallback_location: root_path)
    else
      render json: @test.edit_as_json
    end

  end

  def edit
    @applications = ApplicationTag.select_options
    @environments = EnvironmentTag.select_options
    @types = TestType.all.select_options

    respond_to do |format|
      format.js
    end
  end

  def build
    @response_msg = @test.start_build ? "Build for #{ @test.name } successfully started" : "Error starting job for #{ @test.name }. Token is likely not set."
    respond_to do |format|
      format.js
    end
  end

end
