class EnvironmentTag < ApplicationRecord
  has_many :tests

  def self.find_by_name(env_name)
    if EnvironmentTag.exists?(name: env_name)
      env_tag = EnvironmentTag.where(name: env_name).first
    else
      env_tag = EnvironmentTag.create(name: env_name)
    end

    return env_tag
  end

  def self.all_as_json
    EnvironmentTag.all.as_json(only: [:id, :name])
  end

end
