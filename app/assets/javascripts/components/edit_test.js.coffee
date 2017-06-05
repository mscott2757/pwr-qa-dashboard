@EditTest = React.createClass
  getInitialState: ->
    edit: false

  applicationTagsFormat: ->
    app_tag_names = @props.test.application_tags.map (app_tag) -> app_tag.name
    app_tag_names.join()

  handleToggle: (e) ->
    e.preventDefault()
    @setState edit: !@state.edit

  editTestRow: ->
    React.DOM.tr null,
      React.DOM.td null,
        React.DOM.div
          className: "edit-test-name"
          @props.test.name
        React.DOM.div
          className: "edit-test-toggle"
          React.DOM.a
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

  render: ->
    @editTestRow()

