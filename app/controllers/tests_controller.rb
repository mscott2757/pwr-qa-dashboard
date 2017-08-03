# controller for tests
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
    name = @test.name
    tests = @test.parameterized ? Test.where(name: name) : [ @test ]
    test_params = params[:test]

    app_tags = test_params[:application_tags]
    if test_params[:modal]
      indirect_apps = app_tags.split(", ").map { |app_name| ApplicationTag.find_by_name(app_name) }
    else
      indirect_apps = app_tags ? test_params[:application_tags].map { |app_id| ApplicationTag.find(app_id) } : []
    end

    tests.each do |test|
      primary_app_id = test_params[:primary_app]
      if primary_app_id != "0"
        test.primary_app_id = primary_app_id
      else
        primary_app = test.primary_app
        primary_app.primary_tests.delete(test) if primary_app
      end

      test_type_id = test_params[:test_type]
      if test_type_id != "0"
        test.test_type_id = test_type_id
      else
        test_type = test.test_type
        test_type.tests.delete(test) if test_type
      end

      test.application_tags.delete_all
      test.application_tags.push(*indirect_apps)

      test.group = test_params[:group]
      test.environment_tag_id = test_params[:environment_tag] if !test.parameterized

      test.save
    end

    @test.reload
		flash[:info] = "Successfully updated #{ name }"
    if test_params[:modal]
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
    name = @test.name
    @response_msg = @test.start_build ? "Build for #{ name } successfully started" : "Error starting job for #{ name }. Token is likely not set."
    respond_to do |format|
      format.js
    end
  end

end
