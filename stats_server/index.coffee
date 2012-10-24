
_.templateSettings = {
  escape: /\{\{(?![&])(.+?)\}\}/g
  interpolate: /\{\{&(.+?)\}\}/g
  # evaluate: /<<<(.+?)>>>/g # Uhhh
} if _


template = _.template """
  <tr class="row">
    <td class="name">{{ name }}</td>
    <td class="message_count">{{ message_count }}</td>
    <td class="last_seen">{{ last_seen }}</td>
    <td class="random_message">{{ random_message }}</td>
  </tr>
"""
$.get "get.php", (data) =>
  stats = $("#stats").find("tbody").empty()
  for row in data
    $(template row).appendTo stats


$.get "get.php?action=last_updated", (data) =>
  if data.seconds_ago
    delta = moment().subtract("seconds", data.seconds_ago).fromNow()
    $('<span class="last_updated"> &middot; last updated <span class="time"></span></span>')
      .find(".time").text(delta).end().appendTo $(".footer")


