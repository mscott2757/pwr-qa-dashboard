class TestType < ApplicationRecord
  has_many :tests

  def self.all_as_json
    self.all.as_json(only: [:id, :name])
  end
end
