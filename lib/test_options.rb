# used to encapsulate different method for accessing tests
class TestOptions
  attr_accessor :method, :notes_method, :jira_method, :env_tag

  def initialize(method, env_tag)
    @method = method
    @env_tag = env_tag

    if method == "primary_tests"
      @jira_method = "primary_jira_tickets"
      @notes_method = "primary_notes"
    else
      @jira_method = "indirect_jira_tickets"
      @notes_method = "indirect_notes"
    end
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
