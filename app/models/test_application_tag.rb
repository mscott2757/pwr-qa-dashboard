# This class is used for the has many through relationship between tests and applications
class TestApplicationTag < ApplicationRecord
  belongs_to :test
  belongs_to :application_tag
end
