import Widget from require "lapis.html"

import ChannelFollows from require "saltw.models"

import time_ago_in_words from require "lapis.util"

class Follows extends Widget
  content: =>
    h1 "Follows"

    details ->
      summary "Truncate..."
      form method: "post", ->
        input type: "hidden", name: "csrf_token", value: @csrf_token
        button {
          name: "action"
          value: "truncate"
        }, "Truncate follows"

    element "table", ->
      thead ->
        tr ->
          td "channel"
          td "user_id"
          td "type"
          td "created_at"
          td "followed_at"
          td "just_followed"

      tbody ->
        for follow in *@channel_follows
          tr ->
            td follow.channel
            td ->
              a {
                href: @url_for "twitch_user", user_id: follow.user_id
              }, follow.user_id
            td ChannelFollows.types\to_name follow.type
            td time_ago_in_words follow.created_at
            td time_ago_in_words follow.followed_at
            td ->
              text tostring follow\just_followed!




