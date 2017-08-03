# This model is represents the different environments that a test may run in
class EnvironmentTag < ApplicationRecord
  validates_uniqueness_of :name

  belongs_to :setting, optional: true

  has_many :tests

  def self.find_by_name(env_name)
    exists?(name: env_name) ? where(name: env_name).first : create(name: env_name)
  end

  def self.all_as_json
    all.as_json(only: [:id, :name])
  end

  def self.get_next_env(env_tag)
    env_tag.name == "qa" ? find_by_name("dev") : find_by_name("qa")
  end

  def self.select_options
    all.map{ |env_tag| [env_tag.name, env_tag.id] }
  end
end
