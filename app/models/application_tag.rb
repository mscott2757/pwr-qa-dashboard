class ApplicationTag < ApplicationRecord
  has_many :test_application_tags
  has_many :tests, :through => :test_application_tags
end
