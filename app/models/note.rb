# This class is used for notes, which may be left on apps or individual tests
class Note < ApplicationRecord
  belongs_to :test, optional: true
  belongs_to :application_tag, optional: true
end
