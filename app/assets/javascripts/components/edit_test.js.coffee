@EditTest = React.createClass
  getInitialState: ->
    edit: false

  getDefaultProps: ->
    applications: []
    environments: []
    types: []

  applicationTagsFormat: ->
    app_tag_names = @props.test.application_tags.map (app_tag) -> app_tag.name
    app_tag_names.join(', ')

  mapAppNames: (appNames) ->
    name_to_id = {}
    for app in @props.applications
      name_to_id[app.name] = app.id

    ids = []
    for name in appNames.split(", ")
      ids.push(name_to_id[name]) if name of name_to_id

    return ids

  bindAutocomplete: ->
    appNames = @props.applications.map((app) -> app.name)
    testID = @props.test.id
    $ ->
      split = (val) ->
        val.split( /,\s*/ )

      extractLast = (term) ->
        split(term).pop()

      $("#tags-#{ testID }").on("keydown", (e) ->
          if e.keyCode == $.ui.keyCode.TAB and $(this).autocomplete("instance").menu.active
            e.preventDefault()
        ).autocomplete
          minLength: 0
          source: (request, response) ->
            response($.ui.autocomplete.filter(appNames, extractLast(request.term)))
          focus: ->
            false
          select: (e, ui) ->
            terms = split(this.value)
            terms.pop()
            terms.push ui.item.value
            terms.push ''
            this.value = terms.join(", ")
            false

  componentDidUpdate: (prevProps, prevState) ->
    if @state.edit
      @bindAutocomplete()
      $("#name-input").tooltip()

  handleToggle: (e) ->
    e.preventDefault()
    @setState edit: !@state.edit

  handleEdit: (e) ->
    e.preventDefault()
    env_tag = if @props.test.parameterized then @props.test.environment_tag.id else ReactDOM.findDOMNode(@refs.environment_tag).value

    data =
      primary_app: ReactDOM.findDOMNode(@refs.primary_app).value
      environment_tag: env_tag
      application_tags: @mapAppNames(ReactDOM.findDOMNode(@refs.application_tags).value)
      test_type: ReactDOM.findDOMNode(@refs.test_type).value
      group: ReactDOM.findDOMNode(@refs.group).value
      name: ReactDOM.findDOMNode(@refs.name).value
    $.ajax
      method: 'PUT'
      url: "/tests/#{ @props.test.id }"
      dataType: 'JSON'
      data:
        test: data
      success: (data) =>
        @setState edit: false
        @props.handleEditTest @props.test, data

  stopParent: (e) ->
    e.stopPropagation()

  parameterizedEnvLabel: ->
    React.DOM.a
      className: 'parameterized-env-label'
      "parameterized"

  envDisplay: ->
    if @props.test.parameterized
      return @parameterizedEnvLabel()
    else if "environment_tag" of @props.test
      return @props.test.environment_tag.name
    else
      return ""

  handleDelete: (e) ->
    e.stopPropagation()
    $.ajax
      method: 'DELETE'
      url: "/tests/#{ @props.test.id }"
      dataType: 'JSON'
      success: () =>
        @props.handleDeleteTest @props.test

  testRow: ->
    React.DOM.tr { onClick: @handleToggle },
      React.DOM.td null,
        React.DOM.div { className: "edit-test-name" },
          React.DOM.a { href: @props.test.job_url, className: 'settings-test-link', target: "_blank", onClick: @stopParent }, @props.test.name

      if "test_type" of @props.test
        React.DOM.td null, @props.test.test_type.name
      else
        React.DOM.td null, ""

      React.DOM.td null, @props.test.group

      if "primary_app" of @props.test
        React.DOM.td null, @props.test.primary_app.name
      else
        React.DOM.td null, ""

      React.DOM.td null, @envDisplay()

      React.DOM.td null, @applicationTagsFormat()

      React.DOM.td null,
        React.DOM.a { className: 'btn btn-sm pwr-danger-btn', onClick: @handleDelete }, 'delete'

  defaultTestType: ->
    if "test_type" of @props.test then @props.test.test_type.id else 0

  render: ->
    if !@state.edit
      @testRow()
    else
      React.DOM.tr null,
        React.DOM.td null,
          React.DOM.input { className: 'form-control', id: "name-input", type: "text", ref: 'name', defaultValue: @props.test.name, title: "Warning: Only change name if it has changed on Jenkins" }

        React.DOM.td null,
          React.DOM.select { className: 'form-control', defaultValue: @defaultTestType(), ref: 'test_type' },
            for test_type in @props.types
              React.DOM.option { key: test_type.id, value: test_type.id }, test_type.name
            React.DOM.option { value: 0 }, "None"

        React.DOM.td null,
          React.DOM.input { className: 'form-control', type: "number", ref: 'group', defaultValue: @props.test.group }

        React.DOM.td null,
          React.DOM.select
            className: 'form-control'
            defaultValue: if "primary_app" of @props.test then @props.test.primary_app.id else 0
            ref: 'primary_app'
            for app_tag in @props.applications
              React.DOM.option { key: app_tag.id, value: app_tag.id }, app_tag.name
            React.DOM.option { value: 0 }, "None"

        React.DOM.td null,
          if @props.test.parameterized
            @parameterizedEnvLabel()
          else
            React.DOM.select
              className: 'form-control'
              type: 'text'
              defaultValue: @props.test.environment_tag.id if "environment_tag" of @props.test
              ref: 'environment_tag'
              for env_tag in @props.environments
                React.DOM.option { key: env_tag.id, value: env_tag.id }, env_tag.name

        React.DOM.td null,
          React.DOM.div { className: 'ui-widget' },
            React.DOM.textarea
              className: 'form-control'
              ref: 'application_tags'
              defaultValue: @applicationTagsFormat()
              id: "tags-#{ @props.test.id }"

        React.DOM.td null,
          React.DOM.a { className: 'btn btn-sm pwr-confirm-btn edit-test-update', onClick: @handleEdit }, 'save'
          React.DOM.a { className: 'btn btn-sm pwr-danger-btn', onClick: @handleToggle}, 'cancel'

