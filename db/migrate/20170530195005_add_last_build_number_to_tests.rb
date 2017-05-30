class AddLastBuildNumberToTests < ActiveRecord::Migration[5.1]
  def change
    add_column :tests, :last_build, :integer
  end
end
