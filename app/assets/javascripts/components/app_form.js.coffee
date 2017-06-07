@AppForm = React.createClass
  handleNew: (e) ->
    e.preventDefault()
    name = ReactDOM.findDOMNode(@refs.app_name).value
    $.post("/application_tags", { application_tag: { name: name } }, (data) =>
      @props.handleNewApp data
      , 'JSON')

  render: ->
    React.DOM.div
      className: 'form-inline'
      React.DOM.div
        className: 'form-group'
        React.DOM.input
          type: 'text'
          className: 'form-control'
          placeholder: 'Name'
          ref: "app_name"
        React.DOM.a
          className: 'btn btn-primary'
          onClick: @handleNew
          'Add App'
