
import bind from require "saltw.util"

-- }
--     [20] = {
--         [from_name] = "ArteesGames"
--         [to_id] = "60887114"
--         [from_id] = "119264738"
--         [to_name] = "MoonScript"
--         [followed_at] = "2019-09-16T07:06:05Z"
--     }
-- }


class Twitch extends require "saltw.extension"
  new: (@irc) =>
    @irc\on "irc.before_connect", ->
      @stop = @start_cron 15, bind @, "loop"

  loop: =>
    import ChatCommands, ChannelFollows from require "saltw.models"

    do return

    channel = unpack @irc.channels
    return unless channel


    twitch = ChatCommands\get_twitch!
    res = twitch\get_user_follows {
      to_id: "60887114"
    }

    if res.data
      for follow in *res.data
        channel_follow = ChannelFollows\create {
          user_id: follow.from_id
          :channel
          type: "follow"
          followed_at: follow.followed_at
        }

        if channel_follow.inserted and channel_follow\just_followed!
          @irc\message "Thanks for following #{follow.from_name}"

    
