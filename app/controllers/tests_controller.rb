class TestsController < ApplicationController

  def index
    @tests = Test.edit_all_as_json
    @applications = ApplicationTag.all_as_json
    @environments = EnvironmentTag.all_as_json
		@types = TestType.all_as_json
  end

  def update
    @test = Test.find(params[:id])
    @test.primary_app_id = params[:test][:primary_app] if (params[:test][:primary_app] != "")

		if params[:test][:test_type] != "0"
      @test.test_type_id = params[:test][:test_type]
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
      @test.application_tags.delete(app) if !indirect_apps.include?(app)
    end

    @test.update(group: params[:test][:group], environment_tag_id: params[:test][:environment_tag])

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

  def build
    @test = Test.find(params[:id])
    @test.start_build

    flash[:info] = "Build for #{ @test.name } started"
    respond_to do |format|
      format.js
    end
  end

end
