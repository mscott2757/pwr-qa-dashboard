class TestController < ApplicationController
  def index
    Test.parse_all_tests
    @tests = Test.all
  end
end
