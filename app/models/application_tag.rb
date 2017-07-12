class ApplicationTag < ApplicationRecord
  validates :name, presence: true, allow_blank: false

  has_many :test_application_tags, dependent: :destroy
  has_many :tests, -> { distinct }, through: :test_application_tags
  has_many :indirect_jira_tickets, through: :tests, source: :jira_tickets
  has_many :notes, dependent: :destroy

  has_many :primary_tests, class_name: "Test", foreign_key: "primary_app_id"
  has_many :primary_jira_tickets, through: :primary_tests, source: :jira_tickets

  def self.find_by_name(app_name)
    exists?(name: app_name) ? where(name: app_name).first : create(name: app_name)
  end

  def self.edit_all_as_json
    all.includes(:primary_tests, :tests).as_json(only: [:id, :name, :threshold], include: { primary_tests: { only: [:name, :id] }, tests: { only: [:name, :id] } })
  end

  def self.all_as_json
    all.as_json(only: [:id, :name, :threshold])
  end

  def self.select_options
    all.map{ |app_tag| [app_tag.name, app_tag.id] } << ["None", 0]
  end

  # returns apps with any passing or failing tests in the last 7 days
  def self.relevant_apps(method, env_tag)
    all.select { |app| app.total_recent_tests(method, env_tag) > 0 }.sort_by { |app| app.name.downcase }
  end

  # returns page title for page header
  def self.page_title(method)
    method == "primary_tests" ? "Applications" : "Indirect Applications"
  end

  def self.test_type_display(method)
    method == "primary_tests" ? "Primary Tests" : "Indirect Tests"
  end

  def self.possible_culprits(env_tag)
    relevant_apps("tests", env_tag).select{ |app| app.culprit?(env_tag) }
  end

  def culprit?(env_tag)
    percent_failing(env_tag) >= threshold / 100.0
  end

  def culprit_format(env_tag)
    "Warning #{ total_failing("tests", env_tag) } of #{ total_recent_tests("tests", env_tag) } indirect tests for #{ name } are failing in #{ env_tag.name }"
  end

  def total_recent_tests(method, env_tag)
    total_passing(method, env_tag) + total_failing(method, env_tag)
  end

  def edit_as_json
    as_json(only: [:name, :id, :threshold], include: { primary_tests: { only: [:name, :id] }, tests: { only: [:name, :id] } })
  end

  # returns the portion of an app's tests in and env sorted by name
  def tests_by_env(method, env_tag)
    send(method).select { |test| test.env_tag == env_tag }.sort_by{ |test| test.name.downcase }.sort_by{ |test| test.group || 10 }
  end

  def tests_by_env_json(method, env_tag)
    tests_by_env(method, env_tag).includes(:primary_app, :environment_tag, :test_type, :application_tags).as_json(include: { primary_app: { only: [:name, :id] }, test_type: {only: [:name, :id] }, application_tags: { only: [:name, :id] }, environment_tag: { only: [:name, :id] } })
  end

  def passing_tests(method, env_tag)
    send(method).where(last_build_time: 7.days.ago..Time.now).select { |test| test.env_tag == env_tag and test.passing? }
  end

  def passing_tests_format(method, env_tag)
    passing_tests(method, env_tag).map { |test| test.name }.join(", ")
  end

  def total_passing(method, env_tag)
    passing_tests(method, env_tag).count
  end

  def failing_tests(method, env_tag)
    send(method).where(last_build_time: 7.days.ago..Time.now).select { |test| test.env_tag == env_tag and test.failing? }.sort { |a,b| b.last_build_time <=> a.last_build_time }
  end

  def failing_tests_format(method, env_tag)
    failing_tests(method, env_tag).map { |test| test.name }.join(", ")
  end

  def total_failing(method, env_tag)
    failing_tests(method, env_tag).count
  end

  def percent_failing(env_tag)
    failing = total_failing("tests", env_tag)
    total = failing + total_passing("tests", env_tag)
    (total > 0) ? failing.to_f / total : 0.0
  end

  # obtain which field to query jira tickets, based on method
  def jira_method(method)
    method == "primary_tests" ? "primary_jira_tickets" : "indirect_jira_tickets"
  end

  # obtain unresolved tickets that match environment and method
  def jira_tickets(method, env_tag)
    send(jira_method(method)).select { |ticket| ticket.test.env_tag == env_tag and !ticket.resolved }
  end

end
