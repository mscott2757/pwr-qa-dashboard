class AddEnvironmentTagIdToTests < ActiveRecord::Migration[5.1]
  def change
    add_column :tests, :environment_tag_id, :integer
  end
end
