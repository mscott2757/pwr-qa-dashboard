@AppForm = React.createClass
  getInitialState: ->
    name: ''
    threshold: 100
    group: 10

  handleSubmit: (e) ->
    e.preventDefault()
    data =
      name: ReactDOM.findDOMNode(@refs.name).value
      group: ReactDOM.findDOMNode(@refs.group).value
      threshold: @state.threshold

    $.post "/application_tags", { application_tag: data }, ((data) =>
      @props.handleNewApp data
      @refs.name.value = ""
      @setState name: '')
      , 'JSON'

  handleChange: (e) ->
    @setState "#{ e.target.name }": e.target.value

  componentDidMount: ->
    $("#threshold-slider").slider({
      value: 100
      slide: (e, ui) =>
        @setState threshold: ui.value
    })

  valid: ->
    @state.name and @state.threshold and @state.threshold >= 0 and @state.threshold <= 100

  render: ->
    React.DOM.form { onSubmit: @handleSubmit, className: 'form-inline add-app-form' },
      React.DOM.div { className: 'form-group', id: 'app-form-group' },
        React.DOM.input { type: 'text', className: 'form-control', placeholder: 'Name', name: 'name', ref: "name", onChange: @handleChange }
        React.DOM.input { type: 'number', className: 'form-control app-group-input', placeholder: 'Group', name: 'group', ref: "group", onChange: @handleChange }
        React.DOM.div { className: "threshold-container" },
          React.DOM.p { className: "threshold-label" }, "Threshold"
          React.DOM.div { id: "threshold-slider" }
          React.DOM.p { className: "threshold-display" }, "#{@state.threshold}%"

        React.DOM.button { type: 'submit', className: 'btn btn-primary add-app', disabled: !@valid() }, 'Add App'


