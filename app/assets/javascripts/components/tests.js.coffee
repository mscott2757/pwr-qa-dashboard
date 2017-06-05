@Tests = React.createClass
  getInitialState: ->
    tests: @props.data

  getDefaultProps: ->
    tests: []

  render: ->
    React.DOM.div
      className: 'tests'
      React.DOM.table
        className: 'table table-bordered'
        React.DOM.thead null,
          React.DOM.tr null,
            React.DOM.th null, 'Test'
            React.DOM.th null, 'Application'
            React.DOM.th null, 'Environment'
            React.DOM.th null, 'Indirect Applications'
        React.DOM.tbody null,
          for test in @state.tests
            React.createElement EditTest, key: test.id, test: test

