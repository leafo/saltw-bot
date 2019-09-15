lapis = require "lapis"

import respond_to, capture_errors_json, assert_error from require "lapis.application"

csrf = require "lapis.csrf"

class App extends lapis.Application
  views_prefix: "saltw.web.views"
  flows_prefix: "saltw.web.flows"
  layout: require "saltw.web.views.layout"

  @before_filter =>
    csrf = require "lapis.csrf"
    @csrf_token = csrf.generate_token @

  [stats: "/"]: =>
    @flow("app")\render_home!

  [speak: "/speak"]: capture_errors_json respond_to {
    GET: =>
      render: true

    POST: =>
      shapes = require "saltw.web.util.shapes"
      import types from require "tableshape"

      params = shapes.assert_params @params, {
        message: shapes.limited_text 255
        is_action: shapes.empty / false + types.any / true
      }

      irc = require("saltw.irc.current")
      if params.is_action
        irc\me params.message
      else
        irc\message params.message

      json: {
        success: true
      }
  }

  [channel_user: "/channel-users/:channel_user_id[%d]"]: capture_errors_json respond_to {
    before: =>
      import ChannelUsers from require "saltw.models"
      @channel_user = ChannelUsers\find @params.channel_user_id
      assert_error @channel_user, "invalid user"

    GET: =>
      render: true

    POST: =>
      csrf.assert_token @

      amount = assert tonumber(@params.amount), "invalid number"

      @channel_user\give_point @params.reason, amount

      json: {
        @channel_user
      }
  }


