class TestsController < ApplicationController
  def index
    @tests = Test.edit_all_as_json
    @applications = ApplicationTag.all_as_json
    @environments = EnvironmentTag.all_as_json
  end

  def update
    @test = Test.find(params[:id])

    primary_app = ApplicationTag.find_by_name(params[:test][:primary_app])
    primary_app.primary_tests << @test

    environment = EnvironmentTag.find_by_name(params[:test][:environment_tag])
    environment.tests << @test

    indirect_apps = params[:test][:application_tags].split(',').map { |app_name| ApplicationTag.find_by_name(app_name) }
    indirect_apps.each do |app|
      @test.application_tags << app
    end

    @test.application_tags.reverse.each do |app|
      if !indirect_apps.include?(app)
        @test.application_tags.delete(app)
      end
    end

    render json: { test: @test.as_json(only: [:name, :id, :parameterized], include: { primary_app: { only: [:name, :id] }, application_tags: { only: [:name, :id] }, environment_tag: { only: [:name, :id] } }),
					applications: ApplicationTag.all.as_json(only: [:id, :name]) }
  end

end
