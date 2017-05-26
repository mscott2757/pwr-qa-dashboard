class AddColumnsToTest < ActiveRecord::Migration[5.1]
  def change
    add_column :tests, :status, :string
    add_column :tests, :last_build_url, :string
    add_column :tests, :health_report, :integer
    add_column :tests, :job_url, :string
    add_column :tests, :last_successful_build, :datetime
    add_column :tests, :last_successful_build_url, :string
    add_column :tests, :last_failed_build, :datetime
    add_column :tests, :last_failed_build_url, :string
    add_column :tests, :last_duration, :integer
  end
end
