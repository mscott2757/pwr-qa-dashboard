class CreateEnvironmentTags < ActiveRecord::Migration[5.1]
  def change
    create_table :environment_tags do |t|
      t.string :name

      t.timestamps
    end
  end
end
