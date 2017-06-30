
@htmlEncode = (value) ->
  $('<div/>').html(value).text()

@ticketURL = (ticket) ->
  "https://powerreviews.atlassian.net/browse/#{ticket.number}"

@formatDate = (date) ->
  options =
    hour: '2-digit'
    minute: '2-digit'

  new Date(date).toLocaleString(options)
