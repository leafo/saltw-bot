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
  "lapis"
  "ansicolors",
  "luasocket",
  "lua-cjson",
}

build = {
  type = "builtin",
  modules = {
  }
}

