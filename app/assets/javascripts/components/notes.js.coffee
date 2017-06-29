@Notes = React.createClass
  getInitialState: ->
    notes: @props.notes
    new_note: false

  toggleNotes: ->
    @setState new_note: !@state.new_note

  render: ->
    React.DOM.div
      className: "app-notes-container"
      React.DOM.a
        className: "test-type-tag"
        onClick: @toggleNotes
        "Notes "
