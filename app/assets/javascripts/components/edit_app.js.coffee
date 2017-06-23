@EditApp = React.createClass
  getInitialState: ->
    edit: false

  handleToggle: (e) ->
    e.preventDefault()
    @setState edit: !@state.edit

  handleEdit: (e) ->
    e.preventDefault()
    data =
      name: ReactDOM.findDOMNode(@refs.name).value
      threshold: ReactDOM.findDOMNode(@refs.threshold).value
    $.ajax
      method: 'PUT'
      url: "/application_tags/#{ @props.app.id }"
      dataType: 'JSON'
      data:
        application_tag: data
      success: (data) =>
        @setState edit: false
        @props.handleEditApp @props.app, data

  showModal: (e) ->
    e.preventDefault()
    @props.handleDeleteModal @props.app

  handleDelete: (e) ->
    e.preventDefault()
    $.ajax
      method: 'DELETE'
      url: "/application_tags/#{ @props.app.id }"
      dataType: 'JSON'
      success: () =>
        @props.handleDeleteApp @props.app

  hasTests: ->
    @props.tests.length > 0 or @props.primary_tests.length > 0

  thresholdFormat: ->
    @props.app.threshold + "%"

  editAppForm: ->
    React.DOM.tr null,
      React.DOM.td null,
        React.DOM.input
          className: 'form-control'
          type: 'text'
          defaultValue: @props.app.name
          ref: 'name'
      React.DOM.td null,
        React.DOM.input
          className: 'form-control'
          type: 'type'
          defaultValue: @props.app.threshold
          ref: 'threshold'
      React.DOM.td null,
        React.DOM.a
          className: 'btn btn-default btn-sm edit-test-update'
          onClick: @handleEdit
          'Update'
        React.DOM.a
          className: 'btn btn-danger btn-sm'
          onClick: @handleToggle
          'Cancel'

  editAppRow: ->
    React.DOM.tr null,
      React.DOM.td null, @props.app.name
      React.DOM.td null, @thresholdFormat()
      React.DOM.td null,
        React.DOM.a
          className: 'btn btn-default btn-sm edit-test-update'
          onClick: @handleToggle
          'Edit'
        React.DOM.a
          className: 'btn btn-danger btn-sm'
          onClick: @showModal
          "Delete"

  render: ->
    if @state.edit
      @editAppForm()
    else
      @editAppRow()

