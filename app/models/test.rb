require 'httparty'
require 'nokogiri'
require 'open-uri'

class Test < ApplicationRecord
  has_many :test_application_tags, dependent: :destroy
  has_many :application_tags, -> { distinct }, through: :test_application_tags

  belongs_to :primary_app, class_name: "ApplicationTag", foreign_key: "primary_app_id", optional: true
  belongs_to :environment_tag, optional: true

  def self.edit_all_as_json
    Test.all.includes(:primary_app, :environment_tag, :application_tags).as_json(only: [:name, :id, :parameterized], include: { primary_app: { only: [:name, :id] }, application_tags: { only: [:name, :id] }, environment_tag: { only: [:name, :id] } })
  end

  def self.base_url
    "http://ci.powerreviews.io/job/qa-tests/view/All/"
  end

  def self.save_data_from_jenkins_api
    jobs_json = HTTParty.get("#{base_url}/api/json?tree=jobs[name,url]")
    jobs_json = jobs_json.parsed_response

    jobs_json["jobs"].each do |job|
      name = job["name"]
      if exists?(name: name)
        test = where(name: name).first
      else
        test = new(name: name, job_url: job["url"])
      end

      test_json = test.json_tree("color,lastBuild[number],lastSuccessfulBuild[number],lastFailedBuild[number]")

      # get status of test
      test.status = test_json["color"]

      # last build information
      if test_json["lastBuild"]
        # jump to next test if no new build
        if test.last_build and test.last_build == test_json["lastBuild"]["number"]
          next
        end

        test.last_build = test_json["lastBuild"]["number"]
        last_build_json = test.json_build_tree(test.last_build, "actions[causes[userName],parameters[value]],timestamp")
        test.last_build_time = Time.at(last_build_json["timestamp"]/1000).to_datetime

        parameterized = false
        last_build_json["actions"].each do |action|
          if action["parameters"]
            env_name = action["parameters"][0]["value"]
            env_tag = EnvironmentTag.find_by_name(env_name)
            env_tag.tests << test

            parameterized = true
          end

          if action["causes"]
            test.author = action["causes"][0]["userName"]
          end
        end

        test.parameterized = parameterized
      end

      # last successful build
      if test_json["lastSuccessfulBuild"]
        test.last_successful_build = test_json["lastSuccessfulBuild"]["number"]
        last_successful_build_json = test.json_build_tree(test.last_successful_build, "timestamp")
        test.last_successful_build_time = Time.at(last_successful_build_json["timestamp"]/1000).to_datetime
      end

      # last failed build
      if test_json["lastFailedBuild"]
        test.last_failed_build = test_json["lastFailedBuild"]["number"]
        last_failed_build_json = test.json_build_tree(test.last_failed_build, "timestamp")
        test.last_failed_build_time = Time.at(last_failed_build_json["timestamp"]/1000).to_datetime
      end

      test.save!
    end
  end

  def json_tree(tree_attr)
    response = HTTParty.get("#{job_url}/api/json?tree=#{tree_attr}")
    response.parsed_response
  end

  def json_build_tree(build_number, tree_attr)
    response = HTTParty.get("#{job_url}/#{build_number}/api/json?tree=#{tree_attr}")
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

  def status_css
    if passing?
      return "passing"
    elsif failing?
      return "failing"
    else
      return "other"
    end
  end

  def status_display
    if passing?
      return "passing"
    elsif failing?
      return "failing"
    elsif in_progress?
      return "in progress"
    elsif not_built?
      return "not built"
    elsif aborted?
      return "aborted"
    elsif disabled?
      return "disabled"
    else
      return "N/A"
    end
  end

  def in_progress?
    self.status.include?("anime")
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
