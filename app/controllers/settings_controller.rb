class SettingsController < ApplicationController
  def select_environment
    @setting.change_env(EnvironmentTag.find(params[:id]))
    redirect_back(fallback_location: root_path)
  end
end
