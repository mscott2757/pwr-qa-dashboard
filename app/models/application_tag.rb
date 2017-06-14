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

  def self.all_as_json
    ApplicationTag.all.as_json(only: [:id, :name])
  end

  # returns page title for page header
  def self.page_title(method)
    method == "primary_tests" ? "Applications" : "Indirect Applications"
  end

  def tests_sorted_by_last_build(method)
    self.send(method).sort_by { |test| test.last_build_time.nil? ? Time.at(0) : test.last_build_time }.reverse
  end

  # obtain all passing tests in the past 24 hours
  def passing_tests(method)
    self.send(method).where(last_build_time: 24.hours.ago..Time.now).select { |test| test.passing? }
  end

  def passing_tests_format(method)
    # passing_tests(method).map { |test| test.name }.join("\r\n")
    passing_tests(method).map { |test| test.name }.join(", ")
  end

  def total_passing(method)
    passing_tests(method).count
  end

  def total_passing_format(method)
    total = total_passing(method)
    if total == 1
      return "#{total} passing test"
    else
      return "#{total} passing tests"
    end
  end

  # obtain all failing tests in the past 24 hours
  def failing_tests(method)
    self.send(method).where(last_build_time: 24.hours.ago..Time.now).select { |test| test.failing? }
  end

  def failing_tests_format(method)
    # failing_tests(method).map { |test| test.name }.join("\r\n")
    failing_tests(method).map { |test| test.name }.join(", ")
  end

  def total_failing(method)
    failing_tests(method).count
  end

  def total_failing_format(method)
    total = total_failing(method)
    if total == 1
      return "#{total} failing test"
    else
      return "#{total} failing tests"
    end
  end

  def recent_failing_tests(method)
    failing_tests(method).sort { |a,b| b.last_build_time <=> a.last_build_time }.first(3)
  end

  def self.test_type_display(method)
    method == "primary_tests" ? "Primary Tests" : "Indirect Tests"
  end

end
