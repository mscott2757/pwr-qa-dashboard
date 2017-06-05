class TestController < ApplicationController
  def index
    @tests = Test.all.includes(:primary_app, :environment_tag, :application_tags).as_json(only: [:name, :id], include: { primary_app: { only: [:name, :id] }, application_tags: { only: [:name, :id] }, environment_tag: { only: [:name, :id] } })
  end
end
