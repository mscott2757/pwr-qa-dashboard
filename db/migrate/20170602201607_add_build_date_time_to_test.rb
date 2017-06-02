class AddBuildDateTimeToTest < ActiveRecord::Migration[5.1]
  def change
    add_column :tests, :last_build_time, :datetime
    add_column :tests, :last_failed_build_time, :datetime
    add_column :tests, :last_successful_build_time, :datetime
  end
end
