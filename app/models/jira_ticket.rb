# This class is used to encapsulate jira tickets by pulling data from the JIRA API
class JiraTicket < ApplicationRecord
  validates :number, presence: true, allow_blank: false

  belongs_to :test

  def self.save_data_from_jira
    auth = {username: ENV["jira_user"], password: ENV["jira_pass"] }
    all.each do |ticket|
      res = HTTParty.get(ticket.json_url, basic_auth: auth)
      next if res.code == 404 # skip if url doesn't work..
      jira_json = res.parsed_response

      fields = jira_json["fields"]
      ticket.summary = fields["summary"]

      assignee_field = fields["assignee"]
      ticket.assignee = assignee_field["displayName"] if assignee_field

      reporter_field = fields["reporter"]
      ticket.reporter = reporter_field["displayName"] if reporter_field

      status_field = fields["status"]
      ticket.status = status_field["name"] if status_field

      created_field = fields["created"]
      ticket.created = DateTime.parse(created_field) if created_field

      updated_field = fields["updated"]
      ticket.updated = DateTime.parse(updated_field) if updated_field

      ticket.save
    end
  end

  def save_data_from_jira
    auth = {username: ENV["jira_user"], password: ENV["jira_pass"] }
    res = HTTParty.get(json_url, basic_auth: auth)
    return false if res.code == 404

    jira_json = res.parsed_response

    fields = jira_json["fields"]
    self.summary = fields["summary"]

    assignee_field = fields["assignee"]
    self.assignee = assignee_field["displayName"] if assignee_field

    reporter_field = fields["reporter"]
    self.reporter = reporter_field["displayName"] if reporter_field

    status_field = fields["status"]
    self.status = status_field["name"] if status_field

    created_field = fields["created"]
    self.created = DateTime.parse(created_field) if created_field

    updated_field = fields["updated"]
    self.updated = DateTime.parse(updated_field) if updated_field

    self.save

    return true
  end

  def jira_url
    "https://powerreviews.atlassian.net/browse/#{ self.number }"
  end

  def json_url
    "https://powerreviews.atlassian.net/rest/api/2/issue/#{ self.number }?fields=status,reporter,assignee,summary,updated,created"
  end

end
