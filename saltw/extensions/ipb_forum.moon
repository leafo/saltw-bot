-- http://saltworld.net/forums/?app=forums&module=extras&section=newpoststream

json = require "cjson"

options = {
  muted_names: {}
  spammers: setmetatable({}, __index: => 0)
}

class List
  count: 0
  max_items: 4

  all_equal: (val) =>
    return false if #@ == 0

    for thing in *@
      return false if thing != val

    true

  push: (item) =>
    table.insert @, item

    if #@ > @max_items
      table.remove @, 1

options.post_chain = List!

allowed_to_show_post = (name) ->
  return false if options.muted_names[name]

  if options.post_chain\all_equal name
    options.spammers[name] += 1

    if options.spammers[name] > 4
      options.muted_names[name] = true

    return false

  options.post_chain\push name
  true

class IPBFeed
  new: =>
    @last_posts = nil

  parse_posts: (text) =>
    local data
    success, err = pcall ->
      data = json.decode text

    unless success
      print "There was an error parsing json"
      print err
      return

    data.posts

  get_new_posts: (text) =>
    posts = @parse_posts text

    new_posts = {}
    return new_posts unless posts
    if @last_posts
      new_posts = for p in *posts
        continue if @last_posts[p.pid]
        p

    @last_posts = {p.pid, true for p in *posts}
    new_posts

  url_for_post: (post) =>
    "http://saltworld.net/p#{post.pid}"

  format_message: (irc, channels, post) =>
    post_type = post.new_topic == 0 and "reply in" or "topic"

    with irc
      \me {
        \color "grey",    irc.config.message_prefix..post_type
        \color "orange",  " " .. post.title
        \color "grey",    " ["..post.forum_name.."] by "
        \color "green",   post.author_name
        \color "grey",    " > "
        @url_for_post post
      }, channels

class IPBForum extends require "saltw.extension"
  new: (@irc) =>
    return unless @irc.config.ipb

    @url = @irc.config.ipb.url
    @channels = @irc.config.ipb.channels

    unless @url and @channels
      print "missing url and channels for ipb extension"
      return

    @feed = IPBFeed!

    @irc.event_loop\add_task {
      name: "Scrape forums"
      time: 10
      interval: 5
      action: @\task
    }

  task: (t) =>
    return if @busy
    @busy = true

    @irc.event_loop\http_get @url, (body) ->
      @busy = false
      for post in *@feed\get_new_posts body
        continue unless allowed_to_show_post post.author_name
        @feed\format_message @irc, @channels, post

