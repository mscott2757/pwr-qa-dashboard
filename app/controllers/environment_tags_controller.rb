# controller for environments
class EnvironmentTagsController < ApplicationController
	skip_before_action :disable_rotate

  def select_environment
		if params[:stop_rotate]
			session[:rotate] = false
		end

    session[:env_id] = params[:id]
    respond_to do |format|
      format.html { redirect_back(fallback_location: root_path) }
      format.json { render json: EnvironmentTag.find(params[:id]).to_json }
    end
  end

  def toggle_rotate
    session[:rotate] = !session[:rotate]
    respond_to do |format|
      format.js
    end
  end
end
