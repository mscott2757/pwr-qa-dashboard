class CreateJiraTickets < ActiveRecord::Migration[5.1]
  def change
    create_table :jira_tickets do |t|
      t.string :ticket_number
      t.string :ticket_url
      t.integer :test_id

      t.timestamps
    end
  end
end
