-- http://saltworld.net/forums/?app=forums&module=extras&section=newpoststream

config = require "config"
state = require "state"
json = require "cjson"

require "util"

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
    "http://saltword.net/p#{post.pid}"

  format_message: (irc, post) =>
    d = decode_html_entities
    post_type = post.new_topic == 0 and "reply in" or "topic"

    with irc
      \me {
        \color "grey",    config.message_prefix..post_type..' '
        \color "orange",  d(post.title)
        \color "grey",    " ["..d(post.forum_name).."] by "
        \color "green",   d(post.author_name)
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
          @ipb\format_message irc, post
  }

{:make_task}

