config = require("lapis.config").get!

DEFAULT_CONFIG = {
  name: 'bladder_x'
  reconnect_time: 15

  message_prefix: 'New ', -- used for New reply, New post

  channels: { }
  verbose: true

  -- smf_feed_url: "http://localhost/smf/index.php?action=.xml"
  -- ipb_feed_url: "http://localhost/posts.json"
  poll_time: 5.0

  -- stats_url: "http://leafo.net/saltw/"
  stats_update_time: 60*3
}

setmetatable config, __index: DEFAULT_CONFIG

