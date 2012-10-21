
require "lxp.lom"

module "misc", package.seeall

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

export ^

class SMFFeed
  new: =>
    @recent_posts = nil

  get_new_posts: (text) =>
    posts = @parse_feed text
    new_posts = {}
    if @recent_posts
      new_posts = for p in *posts
        if not @recent_posts[p.id]
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

      -- unhtml encode some stuff
      entities = { amp: '&', gt: '>', lt: '<' }
      post.subject = post.subject\gsub '&(.-);', (tag) ->
        return entities[tag] if entities[tag]
        '&'..tag..';'

    posts


-- files = {...}
-- if #files > 0
--   smf = SMFFeed
--   require "moon"
--   for f in *files
--     moon.p smf\get_new_posts io.open(f)\read"*a"

