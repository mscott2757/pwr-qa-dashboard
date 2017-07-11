@Note = React.createClass
  handleDelete: (e) ->
    e.preventDefault()
    $.ajax
      method: 'DELETE'
      url: "/notes/#{ @props.note.id }"
      dataType: 'JSON'
      success: () =>
        @props.handleDeleteNote @props.note

  render: ->
    React.DOM.li { className: "note-li" },
      React.DOM.p { className: "note-body" }, @props.note.body
      React.DOM.p { className: "note-author" },
        "#{@props.note.author} - #{formatDate(@props.note.created_at)}"
        React.DOM.a { className: "resolve-link", onClick: @handleDelete }, "remove"
