class ApplicationTag < ApplicationRecord
  validates :name, presence: true, allow_blank: false

  has_many :test_application_tags, dependent: :destroy
  has_many :tests, -> { distinct }, through: :test_application_tags
  has_many :primary_tests, class_name: "Test", foreign_key: "primary_app_id"

  has_many :indirect_jira_tickets, through: :tests, source: :jira_tickets
  has_many :primary_jira_tickets, through: :primary_tests, source: :jira_tickets

  has_many :notes, dependent: :destroy
  has_many :primary_notes, through: :primary_tests, source: :notes
  has_many :indirect_notes, through: :tests, source: :notes

  def self.find_by_name(app_name)
    exists?(name: app_name) ? where(name: app_name).first : create(name: app_name)
  end

  def self.edit_all_as_json
    all.includes(:primary_tests, :tests).as_json(only: [:id, :name, :threshold, :group], include: { primary_tests: { only: [:name, :id] }, tests: { only: [:name, :id] } })
  end

  def self.all_as_json
    all.as_json(only: [:id, :name, :threshold, :group])
  end

  def self.select_options
    all.map{ |app_tag| [app_tag.name, app_tag.id] } << ["None", 0]
  end

  # returns apps with any passing or failing tests in the last 7 days
  def self.relevant_apps(method, env_tag)
    j_method = ApplicationTag.jira_method(method)
    n_method = ApplicationTag.notes_method(method)
    all.includes(method, j_method, n_method).select { |app| app.relevant?(method, env_tag) }
      .sort_by { |app| [ app.group || 10, app.name.downcase ] }
  end

  def relevant?(method, env_tag)
    send(method).includes(:environment_tag).any? { |test| test.env_tag == env_tag }
  end

  def edit_as_json
    as_json(only: [:name, :id, :threshold, :group], include: { primary_tests: { only: [:name, :id] }, tests: { only: [:name, :id] } })
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
    total = total_tests("tests", env_tag)
    percent_failing_f = (total > 0) ? total_failing("tests", env_tag).to_f / total : 0.0
    percent_failing_f >= threshold / 100.0
  end

  def culprit_format(env_tag)
    "Warning #{ total_failing("tests", env_tag) } of #{ total_tests("tests", env_tag) } indirect tests for #{ name } are failing"
  end

  # returns the portion of an app's tests in an env sorted by name
  def tests_by_env(method, env_tag)
    send(method).includes(:environment_tag, :jira_tickets, :notes).select { |test| test.env_tag == env_tag }
  end

  def show_tests_by_env(method, env_tag)
    send(method).includes(:environment_tag, :jira_tickets, :test_type, :notes)
      .select { |test| test.env_tag == env_tag }
      .sort_by{ |test| [ test.group || 10, test.name.downcase ] }
  end

  def passing_tests(method, env_tag)
    send(method).select { |test| test.env_tag == env_tag and test.passing? }
  end

  def total_passing(method, env_tag)
    passing_tests(method, env_tag).count
  end

  def percent_passing(method, env_tag)
    total = total_tests(method, env_tag)
    (total > 0) ? total_passing(method, env_tag).to_f / total * 100 : 0.0
  end

  def failing_tests(method, env_tag)
    send(method).select { |test| test.env_tag == env_tag and test.failing? }
      .sort { |a,b| b.last_build_time <=> a.last_build_time }
  end

  def total_failing(method, env_tag)
    failing_tests(method, env_tag).count
  end

  def percent_failing(method, env_tag)
    total = total_tests(method, env_tag)
    (total > 0) ? total_failing(method, env_tag).to_f / total * 100 : 0.0
  end

  def other_tests(method, env_tag)
    send(method).select { |test| test.env_tag == env_tag and !test.failing? and !test.passing? }
  end

  def total_other(method, env_tag)
    other_tests(method, env_tag).count
  end

  def percent_other(method, env_tag)
    total = total_tests(method, env_tag)
    (total > 0) ? total_other(method, env_tag).to_f / total * 100 : 0.0
  end

  def total_tests(method, env_tag)
    send(method).select { |test| test.env_tag == env_tag }.count
  end

  def self.jira_method(method)
    method == "primary_tests" ? "primary_jira_tickets" : "indirect_jira_tickets"
  end

  # obtain tickets that match environment and method
  def jira_tickets(method, env_tag)
    send(ApplicationTag.jira_method(method)).select { |ticket| ticket.test.env_tag == env_tag }
  end

  def self.notes_method(method)
    method == "primary_tests" ? "primary_notes" : "indirect_notes"
  end

  # get all notes for an app and its tests
  def all_notes(method)
    notes + send(ApplicationTag.notes_method(method))
  end
end
