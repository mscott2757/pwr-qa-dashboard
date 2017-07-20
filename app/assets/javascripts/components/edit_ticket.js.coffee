@EditTicket = React.createClass
  getInitialState: ->
    edit: false

  handleToggle: (e) ->
    e.preventDefault()
    @setState edit: !@state.edit

  handleEdit: (e) ->
    e.preventDefault()
    data =
      number: ReactDOM.findDOMNode(@refs.number).value
    $.ajax
      method: 'PUT'
      url: "/jira_tickets/#{ @props.ticket.id }"
      dataType: 'JSON'
      data:
        jira_ticket: data
      success: (data) =>
        @setState edit: false
        @props.handleEditTicket @props.ticket, data

  handleDelete: (e) ->
    e.preventDefault()
    $.ajax
      method: 'DELETE'
      url: "/jira_tickets/#{ @props.ticket.id }"
      dataType: 'JSON'
      success: () =>
        @props.handleDeleteTicket @props.ticket

  editTicketRow: ->
    React.DOM.tr null,
      React.DOM.td null, @props.ticket.number
      React.DOM.td null, @props.ticket.test.name
      React.DOM.td null,
        React.DOM.a { className: 'btn btn-default btn-sm edit-test-update', onClick: @handleToggle}, 'Edit'
        React.DOM.a { className: 'btn btn-danger btn-sm edit-test-update', onClick: @handleDelete }, 'Delete'

  editTicketForm: ->
    React.DOM.tr null,
      React.DOM.td null,
        React.DOM.input { className: 'form-control', type: 'text', defaultValue: @props.ticket.number, ref: 'number' }

      React.DOM.td null, @props.ticket.test.name

      React.DOM.td null,
        React.DOM.a { className: 'btn btn-default btn-sm edit-test-update', onClick: @handleEdit }, 'Update'
        React.DOM.a { className: 'btn btn-danger btn-sm', onClick: @handleToggle }, 'Cancel'

  render: ->
    if !@state.edit
      @editTicketRow()
    else
      @editTicketForm()
