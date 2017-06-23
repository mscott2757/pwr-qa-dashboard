@Tickets = React.createClass
  getInitialState: ->
    edit: false

  render: ->
    React.DOM.div
      className: "tickets"
      React.DOM.h3
        className: "tickets-header"
        "Jira Tickets"
