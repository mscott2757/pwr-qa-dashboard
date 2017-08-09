# QA Build Monitor

## Setup

Install gem dependencies by running
```bash
bundle install
```

Migrate the database
```bash
rake db:migrate
```

To start the cron jobs that fetch data in the background, run the command
```bash
whenever --updated-crontab
```
which utilizes the [Whenever](https://github.com/javan/whenever) gem.

Lastly, install Bower dependencies by running
```bash
rake bower:install
```

## Configuration

Configurable settings are are stored in a file
**config/application.yml**
of the form

```yaml
development:
  jira_user: JIRA_USERNAME
  jira_pass: JIRA_PASSWORD
  param_hour: PARAMETERIZED_HOUR

production:
  jira_user: JIRA_USERNAME
  jira_pass: JIRA_PASSWORD
  param_hour: PARAMETERIZED_HOUR
```

Access to the JIRA API requrires authentication, therefore you must
supply the necessary credentials.

The parameterized hour affects how parameterized tests with the
environment **scheduler** are delegated. Tests with timestamps  before the specified hour (in PST) will
be put in **qa** and tests after will be put in **dev**.

The background jobs are configured by editing the **config/schedule.rb**
file, which looks like

```ruby
every 5.minutes do
  runner "Test.save_data_from_jenkins_api"
  runner "JiraTicket.save_data_from_jira"
end
```

The method **Test#save_data_from_jenkins_api** grabs data from the
Jenkins API and updates database with test data. The method
**JiraTicket#save_data_from_jira** will update all existing JIRA tickets
with data from the JIRA API.

After changing this file run
```bash
whenever --updated-crontab
```
to update the crontab.

Configuration for Bower assets is found in the **bower.json** file.

## Running the App
To run in development
```bash
rails server
```
which will start the server at **localhost:3000**

To run in production, first precompile assets then start the server
```bash
rake assets:precompile RAILS_ENV=production
rails server -e production
```
Alternatively, you can also specify the port with
```bash
rails server -e production -p PORT_NUMBER
```

## Dependencies

* [httparty](https://github.com/jnunemaker/httparty)
* [react-rails](https://github.com/reactjs/react-rails)
* [jquery-rails](https://github.com/rails/jquery-rails)
* [bootstrap-sass](https://github.com/twbs/bootstrap-sass)
* [whenever](https://github.com/javan/whenever)
* [bower-rails](https://github.com/rharriso/bower-rails)
* [bootstrap-notify](https://github.com/mouse0270/bootstrap-notify)
