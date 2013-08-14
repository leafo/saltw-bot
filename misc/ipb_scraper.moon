-- http://saltworld.net/forums/?app=forums&module=extras&section=newpoststream

config = require "config"
state = require "state"
json = require "cjson"

require "util"

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
    else
      options.post_chain\push name

    return false

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

  format_message: (irc, post) =>
    post_type = post.new_topic == 0 and "reply in" or "topic"

    with irc
      \me {
        \color "grey",    config.message_prefix..post_type
        \color "orange",  " " .. post.title
        \color "grey",    " ["..post.forum_name.."] by "
        \color "green",   post.author_name
        \color "grey",    " > "
        @url_for_post post
      }


make_task = ->
  {
    name: "Scrape forums"
    time: 0
    interval: 5
    action: =>
      {:irc, :HTTPRequest} = state
      return if @running
      @running = true
      @ipb = @ipb or IPBFeed!

      HTTPRequest\get config.ipb_feed_url, (body) ->
        @running = false
        for post in *@ipb\get_new_posts body
          continue unless allowed_to_show_post post.author_name
          @ipb\format_message irc, post
  }

{:make_task, :options}

