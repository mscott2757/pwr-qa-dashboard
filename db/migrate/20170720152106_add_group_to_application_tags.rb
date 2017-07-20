class AddGroupToApplicationTags < ActiveRecord::Migration[5.1]
  def change
    add_column :application_tags, :group, :integer, default: 10
  end
end
