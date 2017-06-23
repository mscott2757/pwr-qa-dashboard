class TestType < ApplicationRecord
  has_many :tests

  def self.all_as_json
    self.all.as_json(only: [:id, :name])
  end

  def self.select_options
    self.all.map{ |test_type| [test_type.name, test_type.id] } << ["None", 0]
  end
end
