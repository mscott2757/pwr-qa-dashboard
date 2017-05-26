require 'httparty'
require 'nokogiri'
require 'open-uri'

class Test < ApplicationRecord
  def json_object
    response = HTTParty.get(json_url)
    response.parsed_response
  end

  def self.base_url
    "http://ci.powerreviews.io/job/qa-tests/view/All/"
  end

  def self.parse_all_tests
    doc = Nokogiri::HTML(open(Test.base_url))
    doc.css('tr[id^="job_"]').first(10).each do |tr|
      name = tr["id"]
      name.slice!("job_")

      if !Test.exists?(name: name)
        test = Test.new
        test.name = name

        tds = tr.xpath('./td')
        test.status = tds[0].css('img')[0]["alt"]

        if !tds[1].css('a').empty?
          test.last_build_url = URI.join(base_url, tds[1].css('a')[0]["href"]).to_s
        end

        if tds[1]["data"]
          test.health_report = tds[1]["data"].to_i
        end

        test.job_url = URI.join(base_url, tds[2].css('a')[0]["href"]).to_s

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

        test.save!
      end
    end
  end
end
