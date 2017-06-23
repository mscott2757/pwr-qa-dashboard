@AppForm = React.createClass
  getInitialState: ->
    name: ''
    threshold: 0

  handleSubmit: (e) ->
    e.preventDefault()
    data =
      name: ReactDOM.findDOMNode(@refs.name).value
      threshold: ReactDOM.findDOMNode(@refs.threshold).value

    $.post "/application_tags", { application_tag: data }, ((data) =>
      @props.handleNewApp data
      @clearFields()
      @setState @getInitialState())
      , 'JSON'

  handleChange: (e) ->
    @setState "#{ e.target.name }": e.target.value

  clearFields: ->
    @refs.name.value = ""
    @refs.threshold.value = ""

  valid: ->
    @state.name and @state.threshold and @state.threshold >= 0 and @state.threshold <= 100

  render: ->
    React.DOM.form
      onSubmit: @handleSubmit
      className: 'form-inline add-app-form'
      React.DOM.div
        className: 'form-group'
        React.DOM.input
          type: 'text'
          className: 'form-control'
          placeholder: 'Name'
          name: 'name'
          ref: "name"
          onChange: @handleChange
        React.DOM.input
          type: 'number'
          className: 'form-control'
          placeholder: 'Threshold'
          name: 'threshold'
          ref: "threshold"
          onChange: @handleChange
      React.DOM.button
        type: 'submit'
        className: 'btn btn-primary add-app'
        disabled: !@valid()
        'Add App'
