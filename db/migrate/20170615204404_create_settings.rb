class CreateSettings < ActiveRecord::Migration[5.1]
  def change
    create_table :settings do |t|
      t.boolean :rotate

      t.timestamps
    end
  end
end
