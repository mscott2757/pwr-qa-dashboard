@AppJiraTickets = React.createClass
  getInitialState: ->
    show: false
    mouseDownOnTickets: false

  toggleShow: ->
    @setState show: !@state.show

  pageClick: ->
    return if @state.mouseDownOnTickets
    @setState show: false

  handleMouseDown: ->
    @setState mouseDownOnTickets: true

  handleMouseUp: ->
    @setState mouseDownOnTickets: false

  componentDidMount: ->
    window.addEventListener('mousedown', @pageClick, false)

  ticketList: ->
    React.DOM.ul { className: "sub" },
      for ticket in @props.tickets
        React.DOM.li { className: "sub-li", key: ticket.id },
          React.DOM.a { className: "jira-url-link", href: ticketURL(ticket), target: "_blank" }, ticket.number
          React.DOM.span { className: "test-type-tag", id: "ticket-status" }, ticket.status.toUpperCase() if ticket.status

          React.DOM.div {},
            React.DOM.div { className: "jira-people"},
              React.DOM.span {}, "Assignee: "
              React.DOM.span { className: "jira-person" }, ticket.assignee
            React.DOM.div { className: "jira-people"},
              React.DOM.span {}, "Reporter: "
              React.DOM.span { className: "jira-person" }, ticket.reporter

          React.DOM.p { className: "jira-summary" }, ticket.summary
          React.DOM.p { className: "jira-created" }, "Created on #{formatDate(ticket.created)}" if ticket.created

  render: ->
    React.DOM.div { className: "app-jira-tickets", onMouseDown: @handleMouseDown, onMouseUp: @handleMouseUp },
      React.DOM.a { className: "test-type-tag", id: "active-tickets" if @props.tickets.length, onClick: @toggleShow },
        "JIRA "
        if @props.tickets.length
          React.DOM.span { id: "qa-badge", className: "badge" }, @props.tickets.length

      if @state.show
        @ticketList()

