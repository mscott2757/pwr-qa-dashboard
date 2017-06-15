class AddSettingIdToEnvironmentTag < ActiveRecord::Migration[5.1]
  def change
    add_column :environment_tags, :setting_id, :integer
  end
end
