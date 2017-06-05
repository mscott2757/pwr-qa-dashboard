@EditTest = React.createClass
  getInitialState: ->
    edit: false

  applicationTagsFormat: ->
    app_tag_names = @props.test.application_tags.map (app_tag) -> app_tag.name
    app_tag_names.join()

  handleToggle: (e) ->
    e.preventDefault()
    @setState edit: !@state.edit

  handleEdit: (e) ->
    e.preventDefault()
    data =
      primary_app: ReactDOM.findDOMNode(@refs.primary_app).value
      environment_tag: ReactDOM.findDOMNode(@refs.environment_tag).value
      application_tags: ReactDOM.findDOMNode(@refs.application_tags).value
    $.ajax
      method: 'PUT'
      url: "/tests/#{ @props.test.id }"
      dataType: 'JSON'
      data:
        test: data
      success: (data) =>
        @setState edit: false
        @props.handleEditRecord @props.test, data

  editTestRow: ->
    React.DOM.tr null,
      React.DOM.td null,
        React.DOM.div
          className: "edit-test-name"
          @props.test.name
        React.DOM.div
          className: "edit-test-toggle"
          React.DOM.a
            className: 'btn btn-default btn-sm'
            onClick: @handleToggle
            'Edit'

      if "primary_app" of @props.test
        React.DOM.td null, @props.test.primary_app.name
      else
        React.DOM.td null,

      if "environment_tag" of @props.test
        React.DOM.td null, @props.test.environment_tag.name
      else
        React.DOM.td null,

      React.DOM.td null, @applicationTagsFormat()

  editTestForm: ->
    React.DOM.tr null,
      React.DOM.td null,
        React.DOM.div
          className: "edit-test-name"
          @props.test.name
        React.DOM.div
          className: "edit-test-toggle"
          React.DOM.a
            className: 'btn btn-default btn-sm'
            onClick: @handleEdit
            'update'
          React.DOM.a
            className: 'btn btn-danger btn-sm'
            onClick: @handleToggle
            'cancel'
      React.DOM.td null,
        React.DOM.input
          className: 'form-control'
          type: 'text'
          defaultValue: @props.test.primary_app.name if "primary_app" of @props.test
          ref: 'primary_app'
      React.DOM.td null,
        React.DOM.input
          className: 'form-control'
          type: 'text'
          defaultValue: @props.test.environment_tag.name if "environment_tag" of @props.test
          ref: 'environment_tag'
      React.DOM.td null,
        React.DOM.input
          className: 'form-control'
          type: 'text'
          defaultValue: @applicationTagsFormat()
          ref: 'application_tags'

  render: ->
    if @state.edit
      @editTestForm()
    else
      @editTestRow()

