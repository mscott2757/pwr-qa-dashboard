class EnvironmentTag < ApplicationRecord
  belongs_to :setting, optional: true

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

  def self.get_next_env(env_tag)
    env_tag.name == "qa" ? self.find_by_name("dev") : self.find_by_name("qa")
  end

  def self.select_options
    self.all.map{ |env_tag| [env_tag.name, env_tag.id] }
  end
end
