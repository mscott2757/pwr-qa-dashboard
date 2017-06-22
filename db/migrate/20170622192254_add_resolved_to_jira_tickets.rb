class AddResolvedToJiraTickets < ActiveRecord::Migration[5.1]
  def change
    add_column :jira_tickets, :resolved, :boolean, default: false
  end
end
