class AddInternalNameToTests < ActiveRecord::Migration[5.1]
  def change
    add_column :tests, :internal_name, :string
  end
end
