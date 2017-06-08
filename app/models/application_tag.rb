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

  def self.page_title(method)
    if method == "primary_tests"
      return "Applications"
    else
      return "Indirect Applications"
    end
  end

  def passing_tests(method)
    self.send(method).select { |test| test.passing? }
  end

  def failing_tests(method)
    self.send(method).select { |test| test.failing? }
  end

end
