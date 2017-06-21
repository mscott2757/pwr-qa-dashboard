@JiraTickets = React.createClass
  getInitialState: ->
    new_ticket: false
    jira_tickets: @props.test.jira_tickets

  componentDidMount: ->
    test_id = @props.test.id
    $("#jira-toggle-#{ test_id }").click( ->
      if $("#sub-#{ test_id }").css("display") == "none"
        $("#sub-#{ test_id }").css("display", "block")
      else
        $("#sub-#{ test_id }").hide()
    )

  render: ->
    React.DOM.div
      className: "jira-section"
      React.DOM.a
        className: "test-type-tag"
        id: "jira-toggle-#{ @props.test.id }"
        "JIRA"
      if !@state.new_ticket
        React.DOM.ul
          className: "sub"
          id: "sub-#{ @props.test.id }"
          for ticket in @state.jira_tickets
            React.DOM.li
              className: "sub-li"
            React.DOM.a
              className: "sub-a"
              href: ticket.ticket_url
              ticket.ticket_number
