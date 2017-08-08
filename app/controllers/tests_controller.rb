# controller for tests
class TestsController < ApplicationController
  before_action :set_test, only: [:update, :edit, :build, :destroy]

  def set_test
    @test = Test.find(params[:id])
  end

  def index
    @tests = Test.edit_all_as_json
  end

  def update
    name = @test.name
    tests = @test.parameterized ? Test.where(name: name) : [ @test ] # udpate tests with same name to sync across different environments
    test_params = params[:test]

    app_tags = test_params[:application_tags]
    if test_params[:modal]
      indirect_apps = app_tags.split(", ").map { |app_name| ApplicationTag.find_by_name(app_name) }
    else
      indirect_apps = app_tags ? app_tags.map { |app_id| ApplicationTag.find(app_id) } : []
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

      test_app_tags = test.application_tags
      test_app_tags.delete_all
      test_app_tags.push(*indirect_apps)

      test.group = test_params[:group]

      test.name = test_params[:name]
      if !test.parameterized
        test.internal_name = test.name
        test.environment_tag_id = test_params[:environment_tag]
      else
        test.internal_name = "#{ test.name }-#{ test.env_tag.name }"
      end

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
    respond_to do |format|
      format.js
    end
  end

  def build
    if @test.start_build
      flash[:info] = "Build for #{ @test.name } successfully started"
    else
      flash[:info] = "Error starting job for #{ @test.name }. Token is likely not set."
    end

    respond_to do |format|
      format.js
    end
  end

  def destroy
    if @test.parameterized
      Test.where(name: @test.name).each do |test|
        test.destroy
      end
    else
      @test.destroy
    end

		flash[:info] = "Successfully deleted #{ @test.name }"
    head :no_content
  end

end
