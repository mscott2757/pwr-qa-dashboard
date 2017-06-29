@AddJiraForm = React.createClass
  getInitialState: ->
    number: ''

  handleChange: (e) ->
    @setState "#{ e.target.name }": e.target.value

  valid: ->
    @state.number != ''

  handleSumbit: (e) ->
    e.preventDefault()
    data =
      number: ReactDOM.findDOMNode(@refs.number).value
      test_id: @props.test.id

    $.post "/jira_tickets", { jira_ticket: data }, ((data) =>
      @props.handleNewTicket data
      )
      , 'JSON'


  render: ->
    React.DOM.div
      className: "add-ticket-form"
      React.DOM.form
        onSubmit: @handleSumbit
        className: "ticket-form"
        React.DOM.div
          className: "form-group"
          React.DOM.label
            className: "jira-label"
            "Ticket number"
          React.DOM.input
            type: 'text'
            className: 'form-control'
            placeholder: 'Number'
            name: 'number'
            ref: "number"
            onChange: @handleChange

          React.DOM.div
            className: "add-ticket-buttons"
            React.DOM.button
              className: 'btn btn-primary btn-sm'
              disabled: !@valid()
              "Create"
            React.DOM.a
              className: "btn btn-default btn-sm"
              onClick: @props.handleClose
              "Cancel"

