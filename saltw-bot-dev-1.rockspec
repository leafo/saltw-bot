package = "saltw-bot"
version = "dev-1"

source = {
  url = "git://github.com/leafo/saltw-bot.git",
}

description = {
  summary = "A framework for building irc bot in MoonScript",
  homepage = "https://github.com/leafo/saltw-bot",
  maintainer = "Leaf Corcoran <leafot@gmail.com>",
  license = "MIT"
}

dependencies = {
  "lua = 5.1",
  -- "busted", -- just for test
  -- "moonscript", -- just for test

  "ansicolors",
  "cqueues",
  "lapis",
  "lua-cjson",
  "luasocket",
  "slnunicode",
}

build = {
  type = "builtin",
  modules = {
    ["saltw.config"] = "saltw/config.lua",
    ["saltw.db.helpers"] = "saltw/db/helpers.lua",
    ["saltw.dispatch"] = "saltw/dispatch.lua",
    ["saltw.event_loop"] = "saltw/event_loop.lua",
    ["saltw.extension"] = "saltw/extension.lua",
    ["saltw.extensions.admin"] = "saltw/extensions/admin.lua",
    ["saltw.extensions.ipb_forum"] = "saltw/extensions/ipb_forum.lua",
    ["saltw.extensions.midi"] = "saltw/extensions/midi.lua",
    ["saltw.extensions.scramble_vim"] = "saltw/extensions/scramble_vim.lua",
    ["saltw.extensions.speak"] = "saltw/extensions/speak.lua",
    ["saltw.extensions.stats"] = "saltw/extensions/stats.lua",
    ["saltw.extensions.today"] = "saltw/extensions/today.lua",
    ["saltw.extensions.url_titles"] = "saltw/extensions/url_titles.lua",
    ["saltw.hot_loader"] = "saltw/hot_loader.lua",
    ["saltw.irc"] = "saltw/irc.lua",
    ["saltw.irc.parse_message"] = "saltw/irc/parse_message.lua",
    ["saltw.misc.sqlite"] = "saltw/misc/sqlite.lua",
    ["saltw.misc.stats"] = "saltw/misc/stats.lua",
    ["saltw.misc.stats2"] = "saltw/misc/stats2.lua",
    ["saltw.model"] = "saltw/model.lua",
    ["saltw.models"] = "saltw/models.lua",
    ["saltw.models.channel_user_point_logs"] = "saltw/models/channel_user_point_logs.lua",
    ["saltw.models.channel_users"] = "saltw/models/channel_users.lua",
    ["saltw.socket"] = "saltw/socket.lua",
    ["saltw.util"] = "saltw/util.lua",
    ["saltw.web.app"] = "saltw/web/app.lua",
    ["saltw.web.flows.app"] = "saltw/web/flows/app.lua",
    ["saltw.web.views.channel_user"] = "saltw/web/views/channel_user.lua",
    ["saltw.web.views.stats"] = "saltw/web/views/stats.lua",
  }
}

