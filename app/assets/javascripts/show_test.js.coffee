@ShowTest = React.createClass
  render: ->
    React.DOM.div
      className: "test-container"
      React.DOM.div
        className: "test-header"
        React.DOM.a
          className: "link-title"
          href: @props.test.url
          React.DOM.h5
            className: "test-title"
            @props.test.name
        React.DOM.p
          className: "type-title"
          @props.test.test_type.name if @props.test.test_type


      React.DOM.div
        className: "test-body"
