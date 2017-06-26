class TestsController < ApplicationController

  def index
    @tests = Test.edit_all_as_json
    @applications = ApplicationTag.all_as_json
    @environments = EnvironmentTag.all_as_json
		@types = TestType.all_as_json
  end

  def update
    @test = Test.find(params[:id])

    primary_app = ApplicationTag.find(params[:test][:primary_app])
    primary_app.primary_tests << @test

    environment = EnvironmentTag.find(params[:test][:environment_tag])
    environment.tests << @test

		if params[:test][:test_type] != "0"
			test_type = TestType.find(params[:test][:test_type])
			test_type.tests << @test
		elsif @test.test_type
			@test.test_type.tests.delete(@test)
		end

    if params[:test][:modal]
      indirect_apps = params[:test][:application_tags].split(", ").map { |app_name| ApplicationTag.find_by_name(app_name) }
    else
      indirect_apps = params[:test][:application_tags] ? params[:test][:application_tags].map { |app_id| ApplicationTag.find(app_id) } : []
    end

    @test.application_tags.push(*indirect_apps)

    @test.application_tags.reverse.each do |app|
      if !indirect_apps.include?(app)
        @test.application_tags.delete(app)
      end
    end

		flash[:info] = "Successfully updated #{ @test.name }"
    if params[:test][:modal]
      redirect_back(fallback_location: root_path)
    else
      render json: @test.edit_as_json
    end

  end

  def edit
    @test = Test.find(params[:id])
    @applications = ApplicationTag.select_options
    @environments = EnvironmentTag.select_options
    @types = TestType.all.select_options

    respond_to do |format|
      format.js
    end
  end
end
