An irc bot written in MoonScript.

# dependencies

 * [LuaSocket](http://w3.impa.br/~diego/software/luasocket/)
 * [LuaExpat](http://www.keplerproject.org/luaexpat/lom.html)
 * [date](http://luaforge.net/projects/date/)
 * [lsqlite3](http://lua.sqlite.org/index.cgi/index) -- for stats
 * [Lua CJSON](http://www.kyne.com.au/~mark/software/lua-cjson.php) -- for stats

# how to run

    moon main.moon

In order to have the bot identify with server create a file
called `config.lua` and make it return a table with password field:

    return  {
      password = "my-password"
    }

Other settings can also be optionally set in `config.lua`. See the top of
`irc.moon` to see what can be overwritten.
