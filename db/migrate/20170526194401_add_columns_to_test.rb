class AddColumnsToTest < ActiveRecord::Migration[5.1]
  def change
    add_column :tests, :status, :string
    add_column :tests, :job_url, :string
    add_column :tests, :author, :string
    add_column :tests, :last_successful_build, :integer
    add_column :tests, :last_failed_build, :integer
  end
end
