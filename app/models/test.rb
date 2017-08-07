
require 'action_view'
require 'httparty'
require 'open-uri'
require 'uri'
require 'net/http'
require 'set'

include ActionView::Helpers::DateHelper

# This class is used to encapsulate jenkins tests by pulling data from the Jenkins API
class Test < ApplicationRecord
  validates_uniqueness_of :internal_name
  validates :internal_name, presence: true, allow_blank: false
  validates :name, presence: true, allow_blank: false

  has_many :test_application_tags, dependent: :destroy
  has_many :application_tags, -> { distinct }, through: :test_application_tags
  has_many :jira_tickets, dependent: :destroy
  has_many :notes, dependent: :destroy

  belongs_to :primary_app, class_name: "ApplicationTag", foreign_key: "primary_app_id", optional: true
  belongs_to :environment_tag, optional: true
  belongs_to :test_type, optional: true

  def self.base_url
    "http://ci.powerreviews.io/job/qa-tests/view/All/"
  end

  def self.save_data_from_jenkins_api
    jobs_json = HTTParty.get("#{base_url}/api/json?tree=jobs[name,url]")
    jobs_json = jobs_json.parsed_response
    curr_tests = Set.new

    jobs_json["jobs"].each do |job|
      job_url = job["url"]
      name = internal_name = job["name"]
      test_json = Test.json_tree(job_url , "color,lastBuild[number],lastSuccessfulBuild[number],lastFailedBuild[number]")

      test_last_build = test_json["lastBuild"]
      next if !test_last_build

      test_params = {}
      last_build = test_params[:last_build] = test_last_build["number"]
      last_build_json = Test.json_build_tree(job_url, last_build, "actions[causes[userName],parameters[value]],timestamp")
      test_params[:last_build_time] = Time.at(last_build_json["timestamp"]/1000).to_datetime

      env_name = ""
      test_params[:parameterized] = false
      last_build_json["actions"].each do |action|
        if action.key?("parameters")
          env_name = action["parameters"][0]["value"]
          if env_name == "scheduler"
            param_hour = ENV["param_hour"] ? ENV["param_hour"].to_i : 4
            env_name = test_params[:last_build_time].in_time_zone("Pacific Time (US & Canada)").hour < param_hour ? "qa" : "dev"
          end
          internal_name += "-#{env_name}"

          Test.where(internal_name: name).first.destroy if exists?(internal_name: name)
          test_params[:parameterized] = true
        end
      end

      if !test_params[:parameterized]
        name_d = name.downcase
        if name_d.include?("dev")
          env_name = "dev"
        elsif name_d.include?("qa")
          env_name = "qa"
        elsif name_d.include?("prod")
          env_name = "prod"
        end
      end

      curr_tests << internal_name
      if exists?(internal_name: internal_name)
        test = where(internal_name: internal_name).first
      else
        test = Test.new(name: name, internal_name: internal_name, job_url: job_url)
      end

      test_params[:status] = test_json["color"]

      if !env_name.blank?
        env_tag = EnvironmentTag.find_by_name(env_name)
        env_tag.tests << test
      end

      # last successful build
      test_last_successful = test_json["lastSuccessfulBuild"]
      if test_last_successful
        last_successful = test_params[:last_successful_build] = test_last_successful["number"]
        last_successful_build_json = test.json_build_tree(last_successful, "timestamp")
        test_params[:last_successful_build_time] = Time.at(last_successful_build_json["timestamp"]/1000).to_datetime
      end

      test.update(test_params)
      test.save
    end

    # remove old versions of test
    all.each do |test|
      test.destroy if !test.parameterized and !curr_tests.include?(test.internal_name)
    end
  end

  def self.set_internal_names
    Test.all.each do |test|
      if test.parameterized
        test.destroy
      else
        test.internal_name = test.name
        test.save
      end
    end
  end

  def self.edit_all_as_json
    Test.all.includes(:primary_app, :environment_tag, :test_type, :application_tags).uniq{ |test| test.name }.sort_by { |test| test.name.downcase }.as_json(only: [:name, :id, :parameterized, :group, :job_url],
      include: { primary_app: { only: [:name, :id] }, test_type: {only: [:name, :id] }, application_tags: { only: [:name, :id] }, environment_tag: { only: [:name, :id] } })
  end

  def self.json_tree(j_url, tree_attr)
    response = HTTParty.get("#{j_url}/api/json?tree=#{tree_attr}")
    response.parsed_response
  end

  def self.json_build_tree(j_url, build_number, tree_attr)
    response = HTTParty.get("#{j_url}/#{build_number}/api/json?tree=#{tree_attr}")
    response.parsed_response
  end

  def edit_as_json
    self.as_json(only: [:name, :id, :parameterized, :group, :job_url], include: { primary_app: { only: [:name, :id] }, test_type: { only: [:name, :id] }, application_tags: { only: [:name, :id] }, environment_tag: { only: [:name, :id] } })
  end

  def default_test_type_id
    test_type ? self.test_type.id : 0
  end

  def default_primary_app_id
    primary_app ? self.primary_app.id : 0
  end

  def json_tree(tree_attr)
    response = HTTParty.get("#{job_url}/api/json?tree=#{tree_attr}")
    response.parsed_response
  end

  def json_build_tree(build_number, tree_attr)
    response = HTTParty.get("#{job_url}/#{build_number}/api/json?tree=#{tree_attr}")
    response.parsed_response
  end

  def env_tag
    environment_tag
  end

  def build_url
    parameterized ? "#{job_url}/buildWithParameters?token=QaJobToken" : "#{job_url}/build?token=QaJobToken"
  end

  def start_build
    uri = URI(build_url)
    res = parameterized ? Net::HTTP.post_form(uri, { parameters: [{ name: "env", value: env_tag.name }] }) : Net::HTTP.post_form(uri, {})
    res.code == "201"
  end

  def last_build_pst_hr
    last_build_time.in_time_zone("Pacific Time (US & Canada)").hour
  end

  def last_build_url
    "#{job_url}/#{last_build}"
  end

  def last_successful_build_url
    "#{job_url}/#{last_successful_build}"
  end

  def status_css
    passing? ? "passing" : failing? ? "failing" : "other"
  end

  def indirect_apps_display
    application_tags.map{ |app_tag| app_tag.name }.join(", ")
  end

  def last_build_display
    last_build_time.present? ? "#{distance_of_time_in_words(last_build_time, Time.now)} ago" : "N/A"
  end

  def last_successful_build_display
    last_build_time.present? ? "#{distance_of_time_in_words(last_successful_build_time, Time.now)} ago" : "N/A"
  end

  def status_display
    in_progress? ? "in progress" : not_built? ? "not built" : aborted? ? "aborted" : disabled? ? "disabled" : "N/A"
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
