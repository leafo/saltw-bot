lapis = require "lapis"

class App extends lapis.Application
  views_prefix: "saltw.web.views"

  "/": =>
    import ChannelUsers from require "saltw.models"
    @users = ChannelUsers\select "
      where channel = '#moonscript'
      order by messages_count desc limit 100
    "

    render: "stats"
