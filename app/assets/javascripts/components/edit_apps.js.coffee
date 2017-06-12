@EditApps = React.createClass
  getInitialState: ->
    applications: @props.data

  getDefaultProps: ->
    applications: []

  addApp: (app) ->
    apps = @state.applications.slice()
    apps.push(app)
    @setState applications: apps

  deleteApp: (app) ->
    apps = @state.applications.slice()
    index = apps.indexOf app
    apps.splice index, 1
    @replaceState applications: apps

  updateApp: (app, data) ->
    index = @state.applications.indexOf app
    apps = React.addons.update(@state.applications, { $splice: [[index, 1, data]] })
    @replaceState applications: apps

  render: ->
    React.DOM.div
      className: 'edit-applications'
      React.createElement AppForm, handleNewApp: @addApp
      React.DOM.table
        className: 'table table-bordered'
        id: 'edit-apps-table'
        React.DOM.thead null,
          React.DOM.tr null,
            React.DOM.th null, 'Application'
            React.DOM.th null, 'Actions'
        React.DOM.tbody null,
          for app in @state.applications
            React.createElement EditApp, key: app.id, app: app, handleDeleteApp: @deleteApp, handleEditApp: @updateApp

