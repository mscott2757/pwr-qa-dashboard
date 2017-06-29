@TestJira = React.createClass
  getInitialState: ->
    show_tickets: false
    show_form: false
    tickets: @props.tickets

  toggleTickets: ->
    @setState show_tickets: !@state.show_tickets

  toggleForm: ->
    @setState show_form: !@state.show_form
    @setState show_tickets: false

  addTicket: (ticket) ->
    tickets = @state.tickets.slice()
    tickets.push(ticket)
    @setState tickets: tickets
    @setState show_form: false
    @setState show_tickets: true

  resolveTicket: (ticket) ->
    tickets = @state.tickets.slice()
    index = tickets.indexOf ticket
    tickets.splice index, 1
    @replaceState tickets: tickets

  ticketList: ->
    React.DOM.ul
      className: "sub"
      for ticket in @state.tickets
        React.createElement JiraTicket, key: ticket.id, ticket: ticket, handleResolveTicket: @resolveTicket

      React.DOM.li
        className: "add-link"
        key: 0
        React.DOM.a
          className: "jira-url-link"
          onClick: @toggleForm
          "add new ticket"

  render: ->
    React.DOM.div
      className: "app-jira-tickets"
      React.DOM.a
        className: "test-type-tag"
        onClick: @toggleTickets
        "JIRA "
        if @state.tickets.length > 0
          React.DOM.span
            className: "badge"
            "#{@state.tickets.length}"

      if @state.show_tickets
        @ticketList()

      if @state.show_form
        React.createElement AddJiraForm, test: @props.test, handleClose: @toggleForm, handleNewTicket: @addTicket
