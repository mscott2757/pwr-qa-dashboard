@EditApp = React.createClass
  getInitialState: ->
    edit: false
    threshold: @props.app.threshold

  handleToggle: (e) ->
    e.preventDefault()
    @setState edit: !@state.edit

  componentDidUpdate: (prevProps, prevState) ->
    if @state.edit
      $("#threshold-slider-#{ @props.app.id }").slider({
        value: @state.threshold
        slide: (e, ui) =>
          @setState threshold: ui.value
      })

  handleEdit: (e) ->
    e.preventDefault()
    data =
      name: ReactDOM.findDOMNode(@refs.name).value
      threshold: @state.threshold
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
        React.DOM.input { className: 'form-control', type: 'text', defaultValue: @props.app.name, ref: 'name' }

      React.DOM.td null,
        React.DOM.div { className: "app-threshold-container" },
          React.DOM.div { id: "threshold-slider-#{ @props.app.id }", className: "app-threshold-slider" }
          React.DOM.p { className: "app-threshold-display" }, "#{@state.threshold}%"

      React.DOM.td null,
        React.DOM.a { className: 'btn btn-default btn-sm edit-test-update', onClick: @handleEdit }, 'Update'
        React.DOM.a { className: 'btn btn-danger btn-sm', onClick: @handleToggle }, 'Cancel'

  editAppRow: ->
    React.DOM.tr null,
      React.DOM.td null, @props.app.name
      React.DOM.td null, @thresholdFormat()
      React.DOM.td null,
        React.DOM.a { className: 'btn btn-default btn-sm edit-test-update', onClick: @handleToggle }, 'Edit'
        React.DOM.a { className: 'btn btn-danger btn-sm', onClick: @showModal }, "Delete"

  render: ->
    if @state.edit
      @editAppForm()
    else
      @editAppRow()

