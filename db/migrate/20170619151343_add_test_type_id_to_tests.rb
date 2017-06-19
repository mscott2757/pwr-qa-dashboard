class AddTestTypeIdToTests < ActiveRecord::Migration[5.1]
  def change
    add_column :tests, :test_type_id, :integer
  end
end
