@AppForm = React.createClass
  getInitialState: ->
    name: ''

  handleSubmit: (e) ->
    e.preventDefault()
    name = ReactDOM.findDOMNode(@refs.name).value
    $.post "/application_tags", { application_tag: { name: name } }, ((data) =>
      @props.handleNewApp data
      @setState @getInitialState())
      , 'JSON'

  handleChange: (e) ->
    @setState name: e.target.name

  valid: ->
    @state.name

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
      React.DOM.button
        type: 'submit'
        className: 'btn btn-primary add-app'
        disabled: !@valid()
        'Add App'
