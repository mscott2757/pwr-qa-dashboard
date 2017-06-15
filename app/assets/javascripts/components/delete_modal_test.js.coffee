@DeleteModalTest = React.createClass
  render: ->
    React.DOM.li
      className: "list-group-item"
      id: "delete-modal-test"
      @props.test.name
