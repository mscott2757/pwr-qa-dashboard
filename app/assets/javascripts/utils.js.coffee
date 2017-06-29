
@htmlEncode = (value) ->
  $('<div/>').html(value).text()

@ticketURL = (ticket) ->
  "https://powerreviews.atlassian.net/browse/#{ticket.number}"
