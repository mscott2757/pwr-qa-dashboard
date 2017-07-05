@TestJiraTickets = React.createClass
  getInitialState: ->
    show_tickets: false
    show_form: false
    tickets: @props.tickets
    mouseDownOnTickets: false

  toggleTickets: ->
    @setState show_tickets: !@state.show_tickets, show_form: false

  toggleForm: ->
    @setState show_form: !@state.show_form, show_tickets: false

  addTicket: (ticket) ->
    tickets = @state.tickets.slice()
    tickets.push(ticket)
    @setState tickets: tickets, show_form: false, show_tickets: true

  resolveTicket: (ticket) ->
    tickets = @state.tickets.slice()
    index = tickets.indexOf ticket
    tickets.splice index, 1
    @replaceState tickets: tickets, show_tickets: true

  pageClick: ->
    return if @state.mouseDownOnTickets
    @setState show_tickets: false, show_form: false

  handleMouseDown: ->
    @setState mouseDownOnTickets: true

  handleMouseUp: ->
    @setState mouseDownOnTickets: false

  componentDidMount: ->
    window.addEventListener('mousedown', @pageClick, false)

  ticketList: ->
    React.DOM.ul
      className: "sub"
      for ticket in @state.tickets
        React.createElement JiraTicket, key: ticket.id, ticket: ticket, handleResolveTicket: @resolveTicket

      React.DOM.li
        className: "add-link"
        React.DOM.a
          className: "jira-url-link"
          onClick: @toggleForm
          "add new ticket"

  render: ->
    React.DOM.div
      className: "app-jira-tickets"
      onMouseDown: @handleMouseDown
      onMouseUp: @handleMouseUp
      React.DOM.a
        className: "test-type-tag"
        onClick: @toggleTickets
        "JIRA "
        if @state.tickets.length
          React.DOM.span
            className: "badge"
            @state.tickets.length

      if @state.show_tickets
        @ticketList()

      if @state.show_form
        React.createElement JiraForm, test: @props.test, handleClose: @toggleForm, handleNewTicket: @addTicket
