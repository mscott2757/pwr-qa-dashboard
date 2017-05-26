class TestController < ApplicationController
  def index
    @tests = Test.all
  end
end
