An irc/Twitch bot written in MoonScript using [cqueues](https://github.com/wahern/cqueues).

[![](http://leafo.net/dump/twitch-banner.svg)](https://www.twitch.tv/moonscript)


# How to run

    moonc .
    luajit main.lua

In order to have the bot identify with server create a file
called `config.lua` and make it return a table with password field:

    return  {
      password = "my-password"
    }

Other settings can also be optionally set in `config.lua`. See the top of
`irc.moon` to see what can be overwritten.
