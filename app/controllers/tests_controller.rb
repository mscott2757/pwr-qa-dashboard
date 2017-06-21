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

		test_type = TestType.find(params[:test][:test_type])
		test_type.tests << @test

    if params[:test][:modal]
      indirect_apps = params[:test][:application_tags].split(", ").map { |app_name| ApplicationTag.find_by_name(app_name) }
    else
      indirect_apps = params[:test][:application_tags] ? params[:test][:application_tags].map { |app_id| ApplicationTag.find(app_id) } : []
    end

    indirect_apps.each do |app|
      @test.application_tags << app
    end

    @test.application_tags.reverse.each do |app|
      if !indirect_apps.include?(app)
        @test.application_tags.delete(app)
      end
    end

    if params[:test][:modal]
      redirect_back(fallback_location: root_path)
    else
      render json: @test.edit_as_json
    end

  end

  def edit
    @test = Test.find(params[:id])
    @applications = ApplicationTag.all.map{ |app_tag| [app_tag.name, app_tag.id] }
    @environments = EnvironmentTag.all.map{ |env_tag| [env_tag.name, env_tag.id] }
    @types = TestType.all.map{ |test_type| [test_type.name, test_type.id] }
    respond_to do |format|
      format.js
    end
  end
end
