@EditTest = React.createClass
  getInitialState: ->
    edit: false

  getDefaultProps: ->
    applications: []
    environments: []

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
    appNames = @props.applications.map (app) -> app.name
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
            response $.ui.autocomplete.filter(appNames, extractLast(request.term))
            return
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
      if @props.test.parameterized
        @bindTooltip()

  componentDidMount: ->
    if @props.test.parameterized
      @bindTooltip()

  handleToggle: (e) ->
    e.preventDefault()
    @setState edit: !@state.edit

  bindTooltip: ->
    test_id = @props.test.id
    $("#parameterized-#{test_id}").tooltip(25)

  handleEdit: (e) ->
    e.preventDefault()
    if @props.test.parameterized
      env_tag = @props.test.environment_tag.id
    else
      env_tag = ReactDOM.findDOMNode(@refs.environment_tag).value

    data =
      primary_app: ReactDOM.findDOMNode(@refs.primary_app).value
      environment_tag: env_tag
      application_tags: @mapAppNames(ReactDOM.findDOMNode(@refs.application_tags).value)
      test_type: ReactDOM.findDOMNode(@refs.test_type).value
    $.ajax
      method: 'PUT'
      url: "/tests/#{ @props.test.id }"
      dataType: 'JSON'
      data:
        test: data
      success: (data) =>
        @setState edit: false
        @props.handleEditTest @props.test, data

  parameterizedEnvLabel: ->
    React.DOM.a
      className: 'parameterized-env-label'
      title: "This test is parameterized"
      id: "parameterized-#{@props.test.id}"
      @props.test.environment_tag.name

  testRow: ->
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

      React.DOM.td null, @props.test.test_type.name if "test_type" of @props.test
      React.DOM.td null, @props.test.primary_app.name if "primary_app" of @props.test

      React.DOM.td null,
        if @props.test.parameterized
          @parameterizedEnvLabel()
        else
          @props.test.environment_tag.name if "environment_tag" of @props.test

      React.DOM.td null, @applicationTagsFormat()

  render: ->
    if !@state.edit
      @testRow()
    else
      React.DOM.tr null,
        React.DOM.td null,
          React.DOM.div
            className: "edit-test-name"
            @props.test.name
          React.DOM.div
            className: "edit-test-toggle"
            React.DOM.a
              className: 'btn btn-default btn-sm edit-test-update'
              onClick: @handleEdit
              'update'
            React.DOM.a
              className: 'btn btn-danger btn-sm'
              onClick: @handleToggle
              'cancel'

        React.DOM.td null,
          React.DOM.select
            className: 'form-control'
            defaultValue: @props.test.test_type.name if "test_type" of @props.test
            ref: 'test_type'
            for test_type in @props.types
              React.DOM.option
                key: test_type.id
                value: test_type.id
                test_type.name

        React.DOM.td null,
          React.DOM.select
            className: 'form-control'
            defaultValue: @props.test.primary_app.id if "primary_app" of @props.test
            ref: 'primary_app'
            for app_tag in @props.applications
              React.DOM.option
                key: app_tag.id
                value: app_tag.id
                app_tag.name

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
                React.DOM.option
                  key: env_tag.id
                  value: env_tag.id
                  env_tag.name

        React.DOM.td null,
          React.DOM.div
            className: 'ui-widget'
            React.DOM.input
              className: 'form-control'
              ref: 'application_tags'
              defaultValue: @applicationTagsFormat()
              id: "tags-#{ @props.test.id }"

