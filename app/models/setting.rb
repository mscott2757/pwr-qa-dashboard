class Setting < ApplicationRecord
  has_one :environment_tag

  def change_env(env_tag)
    if self.environment_tag
      self.environment_tag.update_attribute(:setting_id, nil)
    end

    self.environment_tag = nil
    self.environment_tag = env_tag
    save!
  end
end
