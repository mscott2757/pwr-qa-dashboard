require 'httparty'
require 'nokogiri'
require 'open-uri'

class Test < ApplicationRecord
  has_many :test_application_tags
  has_many :application_tags, :through => :test_application_tags

  def json_object
    response = HTTParty.get("#{job_url}/api/json?")
    response.parsed_response
  end

  def json_object_with_tree(tree_attr)
    response = HTTParty.get("#{job_url}/api/json?tree=#{tree_attr}")
  end


  def self.base_url
    "http://ci.powerreviews.io/job/qa-tests/view/All/"
  end

  def self.parse_all_tests
    doc = Nokogiri::HTML(open(base_url))
    doc.css('tr[id^="job_"]').first(10).each do |tr|
      name = tr["id"]
      name.slice!("job_")

      if Test.exists?(name: name)
        test = Test.where(name: name).first
      else
        test = Test.new
        test.name = name
      end

      tds = tr.xpath('./td')
      test.status = tds[0].css('img')[0]["alt"]

      # resolve last build url
      if !tds[1].css('a').empty?
        test.last_build_url = URI.join(base_url, tds[1].css('a')[0]["href"]).to_s
      end

      # get health report score
      if tds[1]["data"]
        test.health_report = tds[1]["data"].to_i
      end

      # resolve job url
      test.job_url = URI.join(base_url, tds[2].css('a')[0]["href"]).to_s

      # figure out what applications are relevant to this test
      test_json = test.json_object_with_tree("description")
      test_json["description"].split(',').each do | app_tag |
        if ApplicationTag.exists?(name: app_name )
          app_tag = ApplicationTag.where(name: app_name).first
        else
          app_tag = ApplicationTag.create(name: app_name)
        end

        test.application_tags << app_tag
      end

      # last successful build
      if tds[3]["data"] != "-"
        test.last_successful_build = Time.parse(tds[3]["data"])
        test.last_successful_build_url = URI.join(base_url, tds[3].css('a')[0]["href"]).to_s
      end

      # last failed build
      if tds[4]["data"] != "-"
        test.last_failed_build = Time.parse(tds[4]["data"])
        test.last_failed_build_url = URI.join(base_url, tds[4].css('a')[0]["href"]).to_s
      end

      # duration
      if tds[5]["data"].to_i > 0
        test.last_duration = tds[5]["data"].to_i/1000
      end

      test.save! if test.changed?
    end
  end
end
