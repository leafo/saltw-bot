

import Flow from require "lapis.flow"

class AppFlow extends Flow
  expose_assigns: true

  render_home: =>
    import ChannelUsers from require "saltw.models"
    @users = ChannelUsers\select "
      where channel = '#moonscript'
      order by messages_count desc limit 100
    "
    render: "stats"

