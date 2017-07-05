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
    React.DOM.ul
      className: "sub"
      for ticket in @props.tickets
        React.DOM.li
          key: ticket.id
          className: "sub-li"
          React.DOM.a
            className: "jira-url-link"
            href: ticketURL(ticket)
            ticket.number

  render: ->
    React.DOM.div
      className: "app-jira-tickets"
      onMouseDown: @handleMouseDown
      onMouseUp: @handleMouseUp
      React.DOM.a
        className: "test-type-tag"
        onClick: @toggleShow
        "JIRA "
        if @props.tickets.length
          React.DOM.span
            className: "badge"
            @props.tickets.length

      if @state.show
        @ticketList()

