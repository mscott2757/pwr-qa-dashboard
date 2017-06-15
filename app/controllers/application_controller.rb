class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_environment

  def set_environment
    @setting = Setting.first
    @env_tag = @setting.environment_tag
  end
end
