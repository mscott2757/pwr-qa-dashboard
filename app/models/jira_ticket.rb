class JiraTicket < ApplicationRecord
  validates_uniqueness_of :ticket_number

  belongs_to :test
end
