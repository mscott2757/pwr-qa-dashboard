require 'app_options'

# This model is used to encapsulate different applications
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

  def edit_as_json
    as_json(only: [:name, :id, :threshold, :group], include: { primary_tests: { only: [:name, :id] }, tests: { only: [:name, :id] } })
  end

  def self.culprits(env_tag)
    options = AppOptions.new("tests", env_tag)
    options.relevant_apps.select{ |app| app.culprit?(options) }
  end

  def culprit?(options)
    total = options.total_tests(self)
    percent_failing_f = (total > 0) ? total_failing(options).to_f / total : 0.0
    return percent_failing_f >= threshold / 100.0
  end

  def failing_tests(options)
    send(options.method).select { |test| test.env_tag == options.env_tag and test.failing? }
      .sort { |test_a,test_b| test_b.last_build_time <=> test_a.last_build_time }
  end

  def total_failing(options)
    failing_tests(options).count
  end

end
