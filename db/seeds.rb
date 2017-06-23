# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

Test.save_data_from_jenkins_api

Setting.create

ApplicationTag.create(name: "Read Services")
ApplicationTag.create(name: "Write Services")
ApplicationTag.create(name: "CDM")
ApplicationTag.create(name: "Log Delivery")
ApplicationTag.create(name: "Shared Services")
ApplicationTag.create(name: "Extranet")

TestType.create(name: "Frontend")
TestType.create(name: "Backend")

Test.all.each do |test|
  # EnvironmentTag.find(rand(EnvironmentTag.count) + 1).tests << test
  ApplicationTag.find(rand(ApplicationTag.count) + 1).primary_tests << test
  test.application_tags << ApplicationTag.find(rand(ApplicationTag.count) + 1)
  test.application_tags << ApplicationTag.find(rand(ApplicationTag.count) + 1)

  TestType.find(rand(TestType.count) + 1).tests << test

  if test.id % 5 == 0
    test.jira_tickets << JiraTicket.create(number: test.id.to_s)
  end
end
