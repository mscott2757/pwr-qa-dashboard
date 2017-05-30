class AddAssoicationsToTestApplicationTags < ActiveRecord::Migration[5.1]
  def change
    add_column :test_application_tags, :test_id, :integer
    add_column :test_application_tags, :application_tag_id, :integer
  end
end
