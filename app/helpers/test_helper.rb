# for use with displaying tests in views
module TestHelper

  def status(test)
    if test.in_progress?
      return "in progress"
    elsif test.not_built?
      return "not built"
    elsif test.aborted?
      return "aborted"
    elsif test.disabled?
      return "disabled"
    else
      return "N/A"
    end
  end

  def last_successful_build(test)
    test.last_build_time.present? ? "#{distance_of_time_in_words(test.last_successful_build_time, Time.now)} ago" : "N/A"
  end

  def indirect_apps(test)
    test.application_tags.map{ |app_tag| app_tag.name }.join(", ")
  end

  def last_build(test)
    test.last_build_time.present? ? "#{distance_of_time_in_words(test.last_build_time, Time.now)} ago" : "N/A"
  end

  def status_class(test)
    test.passing? ? "passing" : test.failing? ? "failing" : "other"
  end

  def default_type(test)
    test.test_type.present? ? test.test_type.id : 0
  end

  def default_app(test)
    test.primary_app.present? ? test.primary_app.id : 0
  end

  def percent_passing(tests)
    tests.count{ |test| test.passing? }/tests.count.to_f*100.0
  end

  def percent_other(tests)
    tests.count{ |test| !test.passing? and !test.failing? }/tests.count.to_f*100.0
  end

  def percent_failing(tests)
    tests.count{ |test| test.failing? }/tests.count.to_f*100.0
  end

  def total_passing(tests)
    tests.count{ |test| test.passing? }
  end

  def any_failing?(tests)
    tests.any?{ |test| test.failing? }
  end

  def total_failing(tests)
    tests.count{ |test| test.failing? }
  end

  def all_failing(tests)
    tests.select{ |test| test.failing? }
  end

  def any_tickets?(tests)
    tests.any?{ |test| !test.jira_tickets.empty? }
  end

  def all_tickets(tests)
    tests.map{ |test| test.jira_tickets }.flatten
  end

end
