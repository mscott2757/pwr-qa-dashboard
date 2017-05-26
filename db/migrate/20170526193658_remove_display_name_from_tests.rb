class RemoveDisplayNameFromTests < ActiveRecord::Migration[5.1]
  def change
    remove_column :tests, :display_name, :string
  end
end
