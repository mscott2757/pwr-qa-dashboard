@JiraTicket = React.createClass
  handleResolve: (e) ->
    e.preventDefault()
    $.ajax
      method: 'DELETE'
      url: "/jira_tickets/#{ @props.ticket.id }"
      dataType: 'JSON'
      success: () =>
        @props.handleResolveTicket @props.ticket

  render: ->
    React.DOM.li { className: "sub-li" },
      React.DOM.a { className: "jira-url-link", href: ticketURL(@props.ticket), target: "_blank" }, @props.ticket.number
      React.DOM.span { className: "test-type-tag", id: "ticket-status" }, @props.ticket.status.toUpperCase() if @props.ticket.status
      React.DOM.a { className: "resolve-link", onClick: @handleResolve }, "remove"

      React.DOM.div {},
        React.DOM.div { className: "jira-people"},
          React.DOM.span {}, "Assignee: "
          React.DOM.span { className: "jira-person" }, @props.ticket.assignee
        React.DOM.div { className: "jira-people"},
          React.DOM.span {}, "Reporter: "
          React.DOM.span { className: "jira-person" }, @props.ticket.reporter

      React.DOM.p { className: "jira-summary" },
        React.DOM.span {}, "Summary: "
        @props.ticket.summary
      React.DOM.p { className: "jira-created" }, "Created on #{formatDate(@props.ticket.created)}" if @props.ticket.created
