class AddForeignKeyToTests < ActiveRecord::Migration[5.1]
  def change
    add_column :tests, :primary_app_id, :integer
  end
end
