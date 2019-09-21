lapis = require "lapis"

import respond_to, capture_errors_json, assert_error from require "lapis.application"

csrf = require "lapis.csrf"

db = require "lapis.db"

shapes = require "saltw.web.util.shapes"
import types from require "tableshape"

class App extends lapis.Application
  views_prefix: "saltw.web.views"
  flows_prefix: "saltw.web.flows"
  layout: require "saltw.web.views.layout"

  @before_filter =>
    csrf = require "lapis.csrf"
    @csrf_token = csrf.generate_token @

  [stats: "/"]: =>
    @flow("app")\render_home!

  [commands: "/commands"]: capture_errors_json respond_to {
    GET: =>
      import ChatCommands from require "saltw.models"
      @chat_commands = ChatCommands\select "
        order by created_at desc
      "

      import ChatCommands from require "saltw.models"
      params = shapes.assert_params @params, {
        command_id: shapes.empty + shapes.db_id
      }

      @edit_command = if params.command_id
        ChatCommands\find(params.command_id), "invalid command"

      render: true

    POST: =>
      import ChatCommands from require "saltw.models"

      params = shapes.assert_params @params, {
        command: shapes.limited_text 40
        type: shapes.db_enum ChatCommands.types
        response: shapes.empty + shapes.limited_text 255
        callback: shapes.empty + shapes.limited_text 255
        secret: shapes.empty / false + types.any / true
      }

      import ChatCommands from require "saltw.models"
      command = ChatCommands\create {
        type: params.type
        command: params.command
        secret: params.secret
        data: {
          response: params.response
          callback: params.callback
        }
      }

      redirect_to: @url_for "commands"
  }

  [command: "/commands/:command_id"]: capture_errors_json respond_to {
    before: =>
      import ChatCommands from require "saltw.models"
      params = shapes.assert_params @params, {
        command_id: shapes.db_id
      }

      @command = assert_error ChatCommands\find(params.command_id), "invalid command"

    POST: =>
      params = shapes.assert_params @params, {
        action: types.one_of {
          "enable", "disable", "delete"
        }
      }

      switch params.action
        when "disable"
          @command\update active: false
        when "enable"
          @command\update active: true
        when "delete"
          assert_error @params.confirm, "click confirm"
          @command\delete!

      redirect_to: @url_for "commands"
  }

  [speak: "/speak"]: capture_errors_json respond_to {
    GET: =>
      render: true

    POST: =>
      params = shapes.assert_params @params, {
        message: shapes.limited_text 255
        is_action: shapes.empty / false + types.any / true
      }

      irc = require("saltw.irc.current")
      if params.is_action
        irc\me params.message
      else
        irc\message params.message

      redirect_to: @url_for "speak"
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

      params = shapes.assert_params @params, {
        amount: shapes.number
        reason: shapes.limited_text 255
      }

      @channel_user\give_point params.reason, params.amount

      redirect_to: @url_for @channel_user
  }

  [follows: "/follows"]: respond_to {
    GET: =>
      import ChannelFollows from require "saltw.models"
      @channel_follows = ChannelFollows\select "order by followed_at desc"

      render: true

    POST: capture_errors_json =>
      import ChannelFollows from require "saltw.models"
      csrf.assert_token @

      switch @params.action
        when "truncate"
          db.query "truncate #{db.escape_identifier ChannelFollows\table_name!}"

      json: {
        success: true
      }
  }

  [twitch_user: "/user/:user_id"]: =>
    import ChatCommands from require "saltw.models"
    twitch = ChatCommands\get_twitch!

    user = twitch\get_user id: @params.user_id
    follow = twitch\get_user_follows {
      from_id: @params.user_id
      to_id: "60887114"
    }

    json: {
      user: unpack user.data
      follow: unpack follow.data
    }

  [chat: "/chat"]: =>
    import ChannelUserMessages from require "saltw.models"
    @messages = ChannelUserMessages\select "order by created_at desc limit 40"
    render: true

  [chat: "/empty"]: =>
    render: true
    import ChannelUserMessages from require "saltw.models"


