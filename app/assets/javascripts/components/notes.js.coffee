@Notes = React.createClass
  getInitialState: ->
    notes: @props.notes
    show: false
    new_note: false
    mouseDownOnNotes: false

  toggleNotes: ->
    @setState show: !@state.show, new_note: false

  toggleForm: ->
    @setState new_note: !@state.new_note, show: false

  addNote: (note) ->
    notes = @state.notes.slice()
    notes.push(note)
    @setState notes: notes, new_note: false, show: true

  removeNote: (note) ->
    notes = @state.notes.slice()
    index = notes.indexOf note
    notes.splice index, 1
    @replaceState(notes: notes, show: true)

  pageClick: ->
    return if @state.mouseDownOnNotes
    @setState show: false, new_note: false

  handleMouseDown: ->
    @setState mouseDownOnNotes: true

  handleMouseUp: ->
    @setState mouseDownOnNotes: false

  componentDidMount: ->
    window.addEventListener('mousedown', @pageClick, false)

  notesList: ->
    React.DOM.ul
      className: "notes-sub"
      for note in @state.notes
        React.createElement Note, key: note.id, note: note, handleDeleteNote: @removeNote

      React.DOM.li
        className: "add-link"
        React.DOM.a
          className: "jira-url-link"
          onClick: @toggleForm
          "add new note"

  render: ->
    React.DOM.div
      className: "app-notes-container"
      onMouseDown: @handleMouseDown
      onMouseUp: @handleMouseUp
      React.DOM.a
        className: "test-type-tag"
        onClick: @toggleNotes
        "Notes "
        if @state.notes.length
          React.DOM.span
            className: "badge"
            @state.notes.length

      if @state.show
        @notesList()

      if @state.new_note
        if "test" of @props
          React.createElement NoteForm, test: @props.test, handleNewNote: @addNote, handleClose: @toggleForm
        else
          React.createElement NoteForm, app: @props.app, handleNewNote: @addNote, handleClose: @toggleNotes

