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
  }
}

