class Note < ApplicationRecord
  belongs_to :test, optional: true
  belongs_to :application_tag, optional: true
end
