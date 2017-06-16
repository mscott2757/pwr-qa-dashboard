class EnvironmentTagsController < ApplicationController
  def select_environment
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
