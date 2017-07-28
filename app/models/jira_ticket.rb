class JiraTicket < ApplicationRecord
  validates_uniqueness_of :number
  validates :number, presence: true, allow_blank: false

  belongs_to :test

  def self.edit_all_as_json
    JiraTicket.all.includes(:test).as_json(only: [:number, :id], include: { test: { only: [:name, :id] } } )
  end

  def self.save_data_from_jira
    auth = {username: ENV["jira_user"], password: ENV["jira_pass"] }
    all.each do |ticket|
      res = HTTParty.get(ticket.json_url, basic_auth: auth)
      next if res.code == 404 # skip if url doesn't work..
      jira_json = res.parsed_response

      fields = jira_json["fields"]
      ticket.summary = fields["summary"]
      ticket.assignee = fields["assignee"]["displayName"] if fields["assignee"]
      ticket.reporter = fields["reporter"]["displayName"] if fields["reporter"]
      ticket.status = fields["status"]["name"] if fields["status"]

      ticket.created = DateTime.parse(fields["created"]) if fields["created"]
      ticket.updated = DateTime.parse(fields["updated"]) if fields["updated"]

      ticket.save
    end
  end

  def save_data_from_jira
    auth = {username: ENV["jira_user"], password: ENV["jira_pass"] }
    res = HTTParty.get(json_url, basic_auth: auth)
    return if res.code == 404

    jira_json = res.parsed_response

    fields = jira_json["fields"]
    self.summary = fields["summary"]
    self.assignee = fields["assignee"]["displayName"] if fields["assignee"]
    self.reporter = fields["reporter"]["displayName"] if fields["reporter"]
    self.status = fields["status"]["name"] if fields["status"]

    self.created = DateTime.parse(fields["created"]) if fields["created"]
    self.updated = DateTime.parse(fields["updated"]) if fields["updated"]

    self.save
  end

  def parsed?
    summary.present? || assignee.present? || reporter.present? || status.present? || created.present? || updated.present?
  end

  def edit_as_json
    self.as_json(only: [:number, :id], include: { test: { only: [:name, :id] } } )
  end

  def jira_url
    "https://powerreviews.atlassian.net/browse/#{ self.number }"
  end

  def json_url
    "https://powerreviews.atlassian.net/rest/api/2/issue/#{ self.number }?fields=status,reporter,assignee,summary,updated,created"
  end

end
