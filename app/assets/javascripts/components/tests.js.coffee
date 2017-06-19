@Tests = React.createClass
  getInitialState: ->
    tests: @props.data
    applications: @props.applications

  getDefaultProps: ->
    tests: []
    applications: []
    environments: []

  updateTest: (test, data) ->
    index = @state.tests.indexOf test
    tests = React.addons.update(@state.tests, {$splice: [[index, 1, data]] })

    @replaceState tests: tests

  addApp: (app_tag) ->

  render: ->
    React.DOM.div
      className: 'tests'
      React.DOM.table
        className: 'table table-bordered edit-test-table'
        React.DOM.thead null,
          React.DOM.tr null,
            React.DOM.th null, 'Test'
            React.DOM.th null, 'Type'
            React.DOM.th null, 'Application'
            React.DOM.th null, 'Environment'
            React.DOM.th null, 'Indirect Applications'
        React.DOM.tbody null,
          for test in @state.tests
            React.createElement EditTest, key: test.id, test: test, handleEditTest: @updateTest, applications: @state.applications, environments: @props.environments, types: @props.types

