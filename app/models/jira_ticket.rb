class JiraTicket < ApplicationRecord
  validates_uniqueness_of :number

  belongs_to :test

  def self.base_url
    "https://powerreviews.atlassian.net/browse"
  end

  def self.edit_all_as_json
    JiraTicket.all.includes(:test).as_json(only: [:number, :id, :resolved], include: { test: { only: [:name, :id] } } )
  end

  def edit_as_json
    self.as_json(only: [:number, :id, :resolved], include: { test: { only: [:name, :id] } } )
  end

  def jira_url
    "#{ JiraTicket.base_url }/#{ self.number }"
  end
end
