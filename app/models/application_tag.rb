class ApplicationTag < ApplicationRecord
  has_many :test_application_tags
  has_many :tests, :through => :test_application_tags

  has_many :primary_tests, class_name: "Test", foreign_key: "primary_app_id"

  def self.find_by_name(app_name)
    if ApplicationTag.exists?(name: app_name)
      app_tag = ApplicationTag.where(name: app_name).first
    else
      app_tag = ApplicationTag.create(name: app_name)
    end

    return app_tag
  end

end
