require 'httparty'
require 'nokogiri'
require 'open-uri'

class Test < ApplicationRecord
  has_many :test_application_tags
  has_many :application_tags, :through => :test_application_tags

  belongs_to :environment_tag

  def self.base_url
    "http://ci.powerreviews.io/job/qa-tests/view/All/"
  end

  def self.parse_all_tests
    jobs_json = HTTParty.get("#{base_url}/api/json?tree=jobs[name,url]")
    jobs_json = jobs_json.parsed_response

    jobs_json["jobs"].each do |job|
      name = job["name"]
      if Test.exists?(name: name)
        test = Test.where(name: name).first
      else
        test = Test.new(name: name, job_url: job["url"])
      end

      test_json = test.json_object_with_tree("description,color,healthReport[*],lastBuild[number],lastSuccessfulBuild[number],lastFailedBuild[number]")
      # last build information
      if test_json["lastBuild"]
        # jump to next test if no new build
        if !test.last_build.nil? and test.last_build == test_json["lastBuild"]["number"]
          next
        end
        test.last_build = test_json["lastBuild"]["number"]
      end

      # last successful build
      if test_json["lastSuccessfulBuild"]
        test.last_successful_build = test_json["lastSuccessfulBuild"]["number"]
      end

      # last failed build
      if test_json["lastFailedBuild"]
        test.last_failed_build = test_json["lastFailedBuild"]["number"]
      end

      # get health score
      if test_json["healthReport"] and test_json["healthReport"][0]
        test.health_report = test_json["healthReport"][0]["score"]
      end

      # get status of test
      test.status = test_json["color"]

      # figure out what applications this test is related to
      test_json["description"].split(',').each do | app_name |
        if ApplicationTag.exists?(name: app_name )
          app_tag = ApplicationTag.where(name: app_name).first
        else
          app_tag = ApplicationTag.create(name: app_name)
        end

        test.application_tags << app_tag
      end

      # figure out what environment this test is running in
      last_build_json = HTTParty.get("#{test.last_build_url}/api/json?tree=actions[*[*]]")
      last_build_json = last_build_json.parsed_response

      env_name = "dev" # need to figure out how to get the environment..
      if EnvironmentTag.exists?(name: env_name)
        env_tag = EnvironmentTag.where(name: env_name).first
      else
        env_tag = EnvironmentTag.create(name: env_name)
      end

      if env_tag != test.environment_tag
        if !test.environment_tag.nil?
          test.environment_tag.tests.delete(test)
        end

        env_tag.tests << test
      end

      test.save!
    end
  end

  def json_object
    response = HTTParty.get("#{job_url}/api/json?")
    response.parsed_response
  end

  def json_object_with_tree(tree_attr)
    response = HTTParty.get("#{job_url}/api/json?tree=#{tree_attr}")
    response.parsed_response
  end

  def last_build_url
    "#{job_url}/#{last_build}"
  end

  def last_successful_build_url
    "#{job_url}/#{last_successful_build}"
  end

  def last_failed_build_url
    "#{job_url}/#{last_failed_build}"
  end

  def in_progress?
    self.status.inlcude?("anime")
  end

  def passing?
    self.status == "blue"
  end

  def failing?
    self.status == "red"
  end

  def not_built?
    self.status == "notbuilt"
  end

  def aborted?
    self.status == "aborted"
  end

  def disabled?
    self.status == "disabled"
  end

end
