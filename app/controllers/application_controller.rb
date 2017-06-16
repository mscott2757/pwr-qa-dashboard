class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_environment
  before_action :set_session

  def set_environment
    if !session.include?(:env_id)
      session[:env_id] = EnvironmentTag.first.id
    end

    @env_tag = EnvironmentTag.find(session[:env_id])
  end

  def set_session
    if !session.include?(:rotate)
      session[:rotate] = false
    end
  end
end
