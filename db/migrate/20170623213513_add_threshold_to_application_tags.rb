class AddThresholdToApplicationTags < ActiveRecord::Migration[5.1]
  def change
    add_column :application_tags, :threshold, :integer, default: 100
  end
end
