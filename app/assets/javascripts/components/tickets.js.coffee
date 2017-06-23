@Tickets = React.createClass
  getInitialState: ->
    tickets: @props.tickets

  updateTicket: (ticket, data) ->
    index = @state.tickets.indexOf ticket
    tickets = React.addons.update(@state.tickets, { $splice: [[index, 1, data]] })
    @replaceState tickets: tickets

  deleteApp: (ticket) ->
    tickets = @state.tickets.slice()
    index = tickets.indexOf ticket
    tickets.splice index, 1
    @replaceState tickets: tickets

  render: ->
    React.DOM.div
      className: "edit-tickets"
      React.DOM.table
        className: 'table table-bordered'
        id: 'edit-apps-table'
        React.DOM.thead null,
          React.DOM.tr null,
            React.DOM.th null, 'Ticket'
            React.DOM.th null, 'Resolved'
            React.DOM.th null, 'Test'
            React.DOM.th null, 'Actions'
        React.DOM.tbody null,
          for ticket in @state.tickets
            React.createElement EditTicket, key: ticket.id, ticket: ticket, handleEditTicket: @updateTicket, handleDeleteTicket: @deleteApp
