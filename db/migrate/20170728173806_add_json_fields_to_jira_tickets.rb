class AddJsonFieldsToJiraTickets < ActiveRecord::Migration[5.1]
  def change
    add_column :jira_tickets, :summary, :text
    add_column :jira_tickets, :assignee, :string
    add_column :jira_tickets, :reporter, :string
    add_column :jira_tickets, :status, :string
    add_column :jira_tickets, :created, :datetime
    add_column :jira_tickets, :updated, :datetime
  end
end
