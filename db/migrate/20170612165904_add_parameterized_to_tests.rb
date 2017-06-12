class AddParameterizedToTests < ActiveRecord::Migration[5.1]
  def change
    add_column :tests, :parameterized, :boolean, default: false
  end
end
