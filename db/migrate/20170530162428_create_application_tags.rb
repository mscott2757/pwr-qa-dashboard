class CreateApplicationTags < ActiveRecord::Migration[5.1]
  def change
    create_table :application_tags do |t|
      t.string :name

      t.timestamps
    end
  end
end
