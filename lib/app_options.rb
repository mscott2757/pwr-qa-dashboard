# used to encapsulate different method for accessing tests
class AppOptions
  attr_accessor :method, :notes_method, :jira_method, :env_tag, :test_type_display, :page_title

  def initialize(method, env_tag)
    @method = method
    @env_tag = env_tag

    if method == "primary_tests"
      @jira_method = "primary_jira_tickets"
      @notes_method = "primary_notes"
      @test_type_display = "Primary Tests"
      @page_title = "Applications"
    else
      @jira_method = "indirect_jira_tickets"
      @notes_method = "indirect_notes"
      @test_type_display = "Indirect Tests"
      @page_title = "Indirect Applications"
    end
  end

  def total_tests(app)
    app.send(method).select { |test| test.env_tag == env_tag }.count
  end

  def env_name
    env_tag.name.upcase
  end

  def relevant?(app)
    app.send(method).includes(:environment_tag).any? { |test| test.env_tag == env_tag }
  end

  def relevant_apps
    ApplicationTag.all.includes(method, jira_method, notes_method).select { |app| relevant?(app) }
      .sort_by { |app| [ app.group || 10, app.name.downcase ] }
  end

  def tests_by_env(app)
    app.send(method).includes(:environment_tag, :jira_tickets, :notes).select { |test| test.env_tag == env_tag }
  end

  def show_tests_by_env(app)
    app.send(method).includes(:environment_tag, :jira_tickets, :test_type, :notes)
      .select { |test| test.env_tag == env_tag }
      .sort_by{ |test| [ test.group || 10, test.name.downcase ] }
  end

  def jira_tickets(app)
    app.send(jira_method).select { |ticket| ticket.test.env_tag == env_tag }
  end

  def all_notes(app)
    app.notes + app.send(notes_method)
  end
end
