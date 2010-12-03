# dependencies

 * [LuaSocket](http://w3.impa.br/~diego/software/luasocket/)
 * [LuaExpat](http://www.keplerproject.org/luaexpat/lom.html)
 * [date](http://luaforge.net/projects/date/)

# how to run

    lua irc.lua

In order to have the bot identify with server create a file
called `config.lua` and make it return a table with password field:

    return  {
		password: "my-password"
	}

Other settings can also be optionally set in `config.lua`. See the top of
`irc.lua` to see what can be overwritten.
