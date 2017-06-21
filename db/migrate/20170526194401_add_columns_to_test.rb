class AddColumnsToTest < ActiveRecord::Migration[5.1]
  def change
    add_column :tests, :status, :string
    add_column :tests, :job_url, :string
    add_column :tests, :last_successful_build, :integer
  end
end
