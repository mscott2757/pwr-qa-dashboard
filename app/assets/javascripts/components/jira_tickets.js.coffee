@JiraTickets = React.createClass
  getInitialState: ->
    show: false

  toggleShow: ->
    @setState show: !@state.show

  ticketList: ->
    React.DOM.ul
      className: "sub"
      for ticket in @props.tickets
        React.DOM.li
          key: ticket.id
          className: "sub-li"
          React.DOM.a
            className: "jira-url-link"
            href: ticketURL(ticket)
            "#{ticket.number}"

  render: ->
    React.DOM.div
      className: "app-jira-tickets"
      React.DOM.a
        className: "test-type-tag"
        onClick: @toggleShow
        "JIRA "
        if @props.tickets.length > 0
          React.DOM.span
            className: "badge"
            "#{@props.tickets.length}"

      if @state.show
        @ticketList()

