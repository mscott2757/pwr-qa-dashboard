class CreateNotes < ActiveRecord::Migration[5.1]
  def change
    create_table :notes do |t|
      t.string :author
      t.text :body
      t.integer :test_id
      t.integer :application_tag_id

      t.timestamps
    end
  end
end
