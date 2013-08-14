
require "lxp.lom"
require "util"

state = require "state"
config = require "config"

options = {
  muted_names: {}
}

deep_insert = (tbl, stack, value) ->
  for i, name in ipairs stack
    if i == #stack
      tbl[name] = value
    else
      tbl[name] = tbl[name] or {}
      tbl = tbl[name]

find = (tbl, item) ->
  for thing in *tbl
    return true if thing == item
  false


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


class SMFFeed
  new: =>
    @recent_posts = nil

  get_new_posts: (text) =>
    posts = @parse_feed text
    new_posts = {}
    if @recent_posts
      new_posts = for p in *posts
        continue if @recent_posts[p.id]
        p

    @recent_posts = {}
    for p in *posts
      @recent_posts[p.id] = true

    new_posts

  -- extract the posts from feed
  parse_feed: (text) =>
    posts = {}
    current_post, tag_stack = nil, {}

    item_tag = "recent-post"
    capture = {
      "subject", "link", "date", "time", "id"
      poster: { "name", "link" }
      board: { "name" }
    }
    
    p = lxp.new {
      StartElement: (name) =>
        if name == item_tag
          current_post = {}
        elseif current_post
           if capture[name]
             capture[name].__root = capture
             capture = capture[name]
           else
             if not find capture, name
               capture = { __root: capture }
           table.insert tag_stack, name
      CharacterData: (string) =>
        if find capture, tag_stack[#tag_stack]
          deep_insert current_post, tag_stack, string

      EndElement: (name) =>
        if current_post
          if name == item_tag
            table.insert posts, current_post
            current_post = nil
          else
            if not find capture, name
              capture = capture.__root

          table.remove tag_stack
    }

    p\parse text
    p\close!

    for post in *posts
      -- shorten link
      if mid = post.link\match '#msg(%d+)'
        post.link = 'http://saltw.net/msg'..mid
      post.subject = decode_html_entities post.subject

    posts


-- files = {...}
-- if #files > 0
--   smf = SMFFeed
--   require "moon"
--   for f in *files
--     moon.p smf\get_new_posts io.open(f)\read"*a"

allowed_to_show_post = (name) ->
  return false if options.muted_names[post.poster.name]
  return false if options.post_chain\all_equal name
  true

make_task = -> {
  name: "Scrape forums"
  time: 0
  interval: 5
  action: =>
    {:irc, :HTTPRequest} = state

    return if @running
    @running = true
    @smf = @smf or SMFFeed!

    HTTPRequest\get config.smf_feed_url, (body) ->
      @running = false
      return unless body
      new_posts = @smf\get_new_posts body

      for post in *new_posts
        continue unless allowed_to_show_post post.poster.name
        options.post_chain\push post.poster.name

        post_type = 'topic'
        if post.subject\match("^Re: ") then
          post.subject = post.subject\sub 5
          post_type = 'reply in'

        with irc
          \me {
            \color "grey",    config.message_prefix..post_type..' '
            \color "orange",  post.subject
            \color "grey",    " ["..post.board.name.."] by "
            \color "green",   post.poster.name
            \color "grey",    " > "
            post.link
          }
}

{ :SMFFeed, :make_task, :options }

