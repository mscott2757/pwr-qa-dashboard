class CreateTestApplicationTags < ActiveRecord::Migration[5.1]
  def change
    create_table :test_application_tags do |t|

      t.timestamps
    end
  end
end
