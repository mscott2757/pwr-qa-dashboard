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
      React.DOM.a { className: "resolve-link", onClick: @handleResolve }, "remove"
