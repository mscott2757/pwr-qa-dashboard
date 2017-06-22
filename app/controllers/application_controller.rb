class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
	before_action :set_cache_headers
  before_action :set_environment
  before_action :set_session

	after_action :flash_to_headers

	def set_cache_headers
    response.headers["Cache-Control"] = "no-cache, no-store"
    response.headers["Pragma"] = "no-cache"
    response.headers["Expires"] = "Fri, 01 Jan 1990 00:00:00 GMT"
  end

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

	def flash_to_headers
		return unless request.xhr?
		response.headers['X-Message'] = flash_message
		response.headers["X-Message-Type"] = flash_type.to_s

		flash.discard # don't want the flash to appear when you reload page
	end

	private

	def flash_message
		[:error, :warning, :success, :info].each do |type|
			return flash[type] unless flash[type].blank?
		end
	end

	def flash_type
		[:error, :warning, :success, :info].each do |type|
			return type unless flash[type].blank?
		end
	end

end
