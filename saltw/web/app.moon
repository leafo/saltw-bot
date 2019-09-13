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

  "/": =>
    @flow("app")\render_home!

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


