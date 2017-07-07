@NoteForm = React.createClass
  getInitialState: ->
    author: ''
    body: ''

  handleChange: (e) ->
    @setState "#{ e.target.name }": e.target.value

  valid: ->
    @state.author and @state.body

  handleSumbit: (e) ->
    e.preventDefault()
    if "test" of @props
      owner = "test_id"
      owner_val = @props.test.id
    else
      owner = "application_tag_id"
      owner_val = @props.app.id

    data =
      author: ReactDOM.findDOMNode(@refs.author).value
      body: ReactDOM.findDOMNode(@refs.body).value
      "#{owner}": owner_val

    $.post "/notes", { note: data }, ((data) =>
      @props.handleNewNote data
      )
      , 'JSON'

  render: ->
    React.DOM.div
      className: "add-note-form"
      React.DOM.form
        onSubmit: @handleSumbit
        className: "note-form"
        React.DOM.div
          className: "form-group"

          React.DOM.input
            type: 'text'
            className: 'form-control add-note-input'
            placeholder: 'Author'
            name: 'author'
            ref: "author"
            onChange: @handleChange

          React.DOM.textarea
            type: 'text'
            className: 'form-control'
            placeholder: 'Body'
            name: 'body'
            ref: "body"
            onChange: @handleChange


          React.DOM.div
            className: "add-ticket-buttons"
            React.DOM.button
              className: 'btn btn-primary btn-sm add-note-btn'
              disabled: !@valid()
              "Create"
            React.DOM.a
              className: "btn btn-default btn-sm add-note-btn"
              onClick: @props.handleClose
              "Cancel"
