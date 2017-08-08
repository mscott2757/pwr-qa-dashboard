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
      group: ReactDOM.findDOMNode(@refs.group).value
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
    e.stopPropagation()
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
        React.DOM.input { className: 'form-control', type: "number", ref: 'group', defaultValue: @props.app.group }

      React.DOM.td null,
        React.DOM.div { className: "app-threshold-container" },
          React.DOM.div { id: "threshold-slider-#{ @props.app.id }", className: "app-threshold-slider" }
          React.DOM.p { className: "app-threshold-display" }, "#{@state.threshold}%"

      React.DOM.td null,
        React.DOM.a { className: 'btn pwr-confirm-btn btn-sm edit-test-update', onClick: @handleEdit }, 'save'
        React.DOM.a { className: 'btn pwr-danger-btn btn-sm', onClick: @handleToggle }, 'cancel'

  editAppRow: ->
    React.DOM.tr { onClick: @handleToggle },
      React.DOM.td null, @props.app.name
      React.DOM.td null, @props.app.group
      React.DOM.td null, @thresholdFormat()
      React.DOM.td null,
        React.DOM.a { className: 'btn pwr-danger-btn btn-sm', onClick: @showModal }, "delete"

  render: ->
    if @state.edit
      @editAppForm()
    else
      @editAppRow()

