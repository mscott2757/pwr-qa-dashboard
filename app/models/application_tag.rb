class ApplicationTag < ApplicationRecord
  has_many :test_application_tags, dependent: :destroy
  has_many :tests, -> { distinct }, through: :test_application_tags

  has_many :primary_tests, class_name: "Test", foreign_key: "primary_app_id"

  def self.find_by_name(app_name)
    app_name = app_name.strip
    if ApplicationTag.exists?(name: app_name)
      app_tag = ApplicationTag.where(name: app_name).first
    else
      app_tag = ApplicationTag.create(name: app_name)
    end

    return app_tag
  end

  def self.edit_all_as_json
    ApplicationTag.all.includes(:primary_tests, :tests).as_json(only: [:id, :name], include: { primary_tests: { only: [:name, :id] }, tests: { only: [:name, :id] } })
  end

  def self.all_as_json
    ApplicationTag.all.as_json(only: [:id, :name])
  end

  def edit_as_json
    self.as_json(only: [:name, :id], include: { primary_tests: { only: [:name, :id] }, tests: { only: [:name, :id] } })
  end

  # returns page title for page header
  def self.page_title(method)
    method == "primary_tests" ? "Applications" : "Indirect Applications"
  end

  def tests_sorted_by_last_build(method, env_tag)
    self.send(method).select { |test| test.env_tag == env_tag }.sort_by { |test| test.last_build_time.nil? ? Time.at(0) : test.last_build_time }.reverse
  end

  def tests_by_env(method, env_tag)
    self.send(method).select { |test| test.env_tag == env_tag }.sort_by{ |test| test.name.downcase }
  end

  def tests_by_env_json(method, env_tag)
    self.tests_by_env(method, env_tag).includes(:primary_app, :environment_tag, :test_type, :application_tags).as_json(include: { primary_app: { only: [:name, :id] }, test_type: {only: [:name, :id] }, application_tags: { only: [:name, :id] }, environment_tag: { only: [:name, :id] } })
  end

  def passing_tests(method, env_tag)
    self.send(method).where(last_build_time: 7.days.ago..Time.now).select { |test| test.passing? and test.env_tag == env_tag }
    # self.send(method).select { |test| test.passing? and test.env_tag == env_tag }
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
    # self.send(method).select { |test| test.failing? and test.env_tag == env_tag }
  end

  def failing_tests_format(method, env_tag)
    failing_tests(method, env_tag).map { |test| test.name }.join(", ")
  end

  def total_failing(method, env_tag)
    failing_tests(method, env_tag).count
  end

  def total_failing_format(method, env_tag)
    total = total_failing(method, env_tag)
    if total == 1
      return "#{total} failing test"
    else
      return "#{total} failing tests"
    end
  end

  def recent_failing_tests(method, env_tag)
    failing_tests(method, env_tag).sort { |a,b| b.last_build_time <=> a.last_build_time }.first(3)
  end

  def self.test_type_display(method)
    method == "primary_tests" ? "Primary Tests" : "Indirect Tests"
  end

end
