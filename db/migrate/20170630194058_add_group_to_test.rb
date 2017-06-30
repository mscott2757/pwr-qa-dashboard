class AddGroupToTest < ActiveRecord::Migration[5.1]
  def change
    add_column :tests, :group, :integer, default: 10
  end
end
