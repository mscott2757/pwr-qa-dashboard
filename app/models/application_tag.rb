class ApplicationTag < ApplicationRecord
  validates :name, presence: true, allow_blank: false

  has_many :test_application_tags, dependent: :destroy
  has_many :tests, -> { distinct }, through: :test_application_tags
  has_many :indirect_jira_tickets, through: :tests, source: :jira_tickets

  has_many :primary_tests, class_name: "Test", foreign_key: "primary_app_id"
  has_many :primary_jira_tickets, through: :primary_tests, source: :jira_tickets

  def self.find_by_name(app_name)
    app_name = app_name.strip
    self.exists?(name: app_name) ? self.where(name: app_name).first : self.create(name: app_name)
  end

  def self.edit_all_as_json
    ApplicationTag.all.includes(:primary_tests, :tests).as_json(only: [:id, :name, :threshold], include: { primary_tests: { only: [:name, :id] }, tests: { only: [:name, :id] } })
  end

  def self.all_as_json
    ApplicationTag.all.as_json(only: [:id, :name, :threshold])
  end

  def self.select_options
    self.all.map{ |app_tag| [app_tag.name, app_tag.id] }
  end

  # returns apps with any passing or failing tests in the last 7 days
  def self.relevant_apps(method, env_tag)
    self.all.select { |app| app.total_passing(method, env_tag) + app.total_failing(method, env_tag) > 0 }
  end

  # returns page title for page header
  def self.page_title(method)
    method == "primary_tests" ? "Applications" : "Indirect Applications"
  end

  def self.test_type_display(method)
    method == "primary_tests" ? "Primary Tests" : "Indirect Tests"
  end

  def self.possible_culprits(env_tag)
    self.relevant_apps("tests", env_tag).map { |app| [app, app.percent_failing(env_tag)] }.select{ |app| app[1] > app[0].threshold / 100.0 }.map { |app| "Warning #{ (app[1] * 100).to_i }% of tests for #{ app[0].name } are failing" }
  end

  def edit_as_json
    self.as_json(only: [:name, :id, :threshold], include: { primary_tests: { only: [:name, :id] }, tests: { only: [:name, :id] } })
  end

  # returns the portion of an app's tests in and env sorted by name
  def tests_by_env(method, env_tag)
    self.send(method).select { |test| test.env_tag == env_tag }.sort_by{ |test| test.name.downcase }
  end

  def tests_by_env_json(method, env_tag)
    self.tests_by_env(method, env_tag).includes(:primary_app, :environment_tag, :test_type, :application_tags).as_json(include: { primary_app: { only: [:name, :id] }, test_type: {only: [:name, :id] }, application_tags: { only: [:name, :id] }, environment_tag: { only: [:name, :id] } })
  end

  def passing_tests(method, env_tag)
    self.send(method).where(last_build_time: 7.days.ago..Time.now).select { |test| test.passing? and test.env_tag == env_tag }
  end

  def passing_tests_format(method, env_tag)
    passing_tests(method, env_tag).map { |test| test.name }.join(", ")
  end

  def total_passing(method, env_tag)
    passing_tests(method, env_tag).count
  end

  def total_passing_format(method, env_tag)
    total = total_passing(method, env_tag)
    total == 1 ? "#{total} passing test" : "#{total} passing tests"
  end

  def failing_tests(method, env_tag)
    self.send(method).where(last_build_time: 7.days.ago..Time.now).select { |test| test.failing? and test.env_tag == env_tag }
  end

  def failing_tests_format(method, env_tag)
    failing_tests(method, env_tag).map { |test| test.name }.join(", ")
  end

  def total_failing(method, env_tag)
    failing_tests(method, env_tag).count
  end

  def total_failing_format(method, env_tag)
    total = total_failing(method, env_tag)
    (total == 1) ? "#{total} failing test" : "#{total} failing tests"
  end

  def percent_failing(env_tag)
    failing = self.total_failing("tests", env_tag)
    total = failing + self.total_passing("tests", env_tag)
    (total > 0) ? failing.to_f / total : 0.0
  end

  # returns 3 most recent failing tests
  def recent_failing_tests(method, env_tag)
    failing_tests(method, env_tag).sort { |a,b| b.last_build_time <=> a.last_build_time }.first(3)
  end

  # obtain which field to query jira tickets, based on method
  def jira_method(method)
    method == "primary_tests" ? "primary_jira_tickets" : "indirect_jira_tickets"
  end

  # obtain unresolved tickets that match environment and method
  def jira_tickets(method, env_tag)
    self.send(jira_method(method)).select { |ticket| ticket.test.env_tag == env_tag and !ticket.resolved }
  end

end
