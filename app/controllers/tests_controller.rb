class TestsController < ApplicationController
  def index
    @tests = Test.all.includes(:primary_app, :environment_tag, :application_tags).as_json(only: [:name, :id], include: { primary_app: { only: [:name, :id] }, application_tags: { only: [:name, :id] }, environment_tag: { only: [:name, :id] } })
  end

  def update
    @test = Test.find(params[:id])

    primary_app = ApplicationTag.find_by_name(params[:test][:primary_app])
    primary_app.primary_tests << @test

    environment = EnvironmentTag.find_by_name(params[:test][:environment_tag])
    environment.tests << @test

    indirect_apps = params[:test][:application_tags].split(',').map { |app_name| ApplicationTag.find_by_name(app_name.strip) }
    indirect_apps.each do |app|
      @test.application_tags << app
    end

    @test.application_tags.reverse.each do |app|
      if !indirect_apps.include?(app)
        @test.application_tags.delete(app)
      end
    end

    render json: @test.as_json(only: [:name, :id], include: { primary_app: { only: [:name, :id] }, application_tags: { only: [:name, :id] }, environment_tag: { only: [:name, :id] } })
  end

end
