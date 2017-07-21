@Tests = React.createClass
  getInitialState: ->
    curr_tests: @props.data
    all_tests: @props.data


  search: (e) ->
    query = e.target.value.toLowerCase()
    if query != ""
      query_result = []
      for test in @state.all_tests
        query_result.push(test) if test.name.toLowerCase().indexOf(query) != -1

      @setState curr_tests: query_result
    else
      @setState curr_tests: @state.all_tests

  getDefaultProps: ->
    tests: []
    applications: []
    environments: []

  updateTest: (test, data) ->
    index = @state.curr_tests.indexOf test
    curr_tests = React.addons.update(@state.curr_tests, {$splice: [[index, 1, data]] })

    index = @state.all_tests.indexOf test
    all_tests = React.addons.update(@state.all_tests, {$splice: [[index, 1, data]] })

    @replaceState curr_tests: curr_tests, all_tests: all_tests

  addApp: (app_tag) ->

  render: ->
    React.DOM.div { className: 'tests' },
      React.DOM.div { className: 'test-search' },
        React.DOM.div { className: 'search-form' },
          React.DOM.input { className: 'form-control', id: 'search-input', placeholder: "Search for a test",  type: "text", onChange: @search }
          React.DOM.img { className: 'search-icon', src: "https://cdn1.iconfinder.com/data/icons/hawcons/32/698627-icon-111-search-512.png" }
      React.DOM.table { className: 'table table-bordered edit-test-table' },
        React.DOM.thead null,
          React.DOM.tr null,
            React.DOM.th null, 'Test'
            React.DOM.th null, 'Type'
            React.DOM.th null, 'Group'
            React.DOM.th null, 'Application'
            React.DOM.th null, 'Environment'
            React.DOM.th null, 'Indirect Applications'
        React.DOM.tbody null,
          for test in @state.curr_tests
            React.createElement EditTest, key: test.id, test: test, handleEditTest: @updateTest, applications: @props.applications, environments: @props.environments, types: @props.types

