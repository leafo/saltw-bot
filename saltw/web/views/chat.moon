import Widget from require "lapis.html"
import ChannelUserMessages from require "saltw.models"

import time_ago_in_words from require "lapis.util"

class Chat extends Widget
  content: =>
    h1 "Chat"

    element "table", ->
      thead ->
        tr ->
          td "channel"
          td "user"
          td "user_id"
          td "message"
          td "data"

      tbody ->
        for message in *@messages
          tr ->
            td message.channel
            td message.name
            td message.user_id
            td message.message
            td ->
              pre require("moon").dump message.data



