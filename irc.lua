
-- how many times have i done this before
-- you can not yield if a for loop

require "socket"
require "socket.url"
-- require "util"
require "feed"

name = 'bladder_x'
host = 'irc.esper.net'
port = 6667

local success, msg = pcall(require, "password")
password = success and msg or nil

poll_time = 5.0 -- time interval for poll

feed_url = 'http://www.saltw.net/index.php?type=rss;action=.xml'
channels = {'#saltw'}

-- host = 'localhost'
-- feed_url = 'http://localhost/smf/index.php?type=rss;action=.xml'

local colors = {
 white  = 0,
 black  = 1,
 blue   = 2,
 green  = 3,
 red    = 4,
 brown  = 5,
 purple = 6,
 orange = 7,
 yellow = 8,
 lime   = 9,
 teal   = 10,
 aqua   = 11,
 royal  = 12,
 pink   = 13,
 grey   = 14,
 silver = 15
}



local client = socket.connect(host, port)
if not client then
	print "could not connect to server"
	return
end
print "connected"

client:send("NICK "..name.."\r\n")
client:send("USER "..(name.." "):rep(3)..":Bildo Bagins\r\n")

local function Buffer() 
	return {
		append = function(self, a) table.insert(self, a) end,
		tostring = function(self, slice)
			local out = table.concat(self)
			if slice then
				out = out:sub(1, #self - (slice or 0))
			end
			return out
		end,
		ends_with = function(self, str)
			local i = #self
			for c in str:reverse():gmatch('.') do
				if i < 1 or self[i] ~= c then return false end
				i = i - 1
			end
			return true
		end
	}
end

local function http_request(url, method)
	method = method or 'GET'
	url = socket.url.parse(url)

	local http = socket.connect(url.host, url.port or 80)
	if not http then
		error("Failed to open connection to "..feed)
	end

	-- print('+++ Requesting ', url.path..'?'..url.query)
	http:send(method..' '..url.path..'?'..url.query..' HTTP/1.1\r\n')
	http:send('host: '..url.host..'\r\n\r\n')
	return http
end


local function get_byte(sck)
	while true do
		local byte, err = sck:receive(1)
		if err == 'closed' then error('socket closed') end
		if err == 'timeout' then
			coroutine.yield()
		else
			return byte
		end
	end
end

local function get_bytes(sck, count)
	local buffer = Buffer()
	while #buffer < count do
		buffer:append(get_byte(sck))
	end

	return buffer:tostring()
end

local function get_line(sck)
	local buffer = Buffer()
	while true do
		buffer:append(get_byte(sck))
		if buffer:ends_with("\r\n") then
			return buffer:tostring(2)
		end
	end
end


local function command_reader(client)
	client:settimeout(0)
	return function() 
		while true do coroutine.yield(get_line(client)) end
	end
end

local function command_responder(client, line)
	-- if line:sub(1, 1) == ':' then return end -- server log
	print('irc:', line)
	local ping = line:match("PING :(.*)")
	if ping then
		client:send("PONG "..ping.."\r\n")
		print('+++', 'PONG')
		return
	end
end

local function http_reader(client)
	client:settimeout(0)
	return function() 
		local header = {}
		while true do
			local line = get_line(client)
			if line == '' then break end
			local name, value = line:match("([^:]+): (.*)")
			if name then header[name] = value end
		end


		if header['Content-Length'] then
			local size = tonumber(header['Content-Length'])
			return get_bytes(client, size)
		elseif header['Transfer-Encoding'] == 'chunked' then
			local chunks = {}
			while true do
				local size = tonumber('0x'..get_line(client))
				if size == 0 then break end

				table.insert(chunks, get_bytes(client, size))
				get_line(client)
			end
			return table.concat(chunks), header
		else 
			error("can't read http response")
		end
	end
end

local tasks = {
	{
		name = 'Join channels',
		time = 1.0,
		run = function(self, irc)

			-- ident
			if password then
				irc:message_to('NickServ', 'IDENTIFY '..password)
			end

			for _,channel in ipairs(channels) do
				irc:join(channel)
			end
		end
	},
	{
		name = 'Scrape forums',
		time = poll_time or 10.0,
		last_date = nil,
		running = false,
		run = function(self, irc)
			if self.running then return true end
			self.running = true
			add_listener(http_request(feed_url), http_reader, function(sck, response, headers)
				self.running = false
				local posts = feed.parse(response, headers.Date)
				if self.last_date then
					for _,post in ipairs(posts) do
						if post.date == self.last_date then break end
						print('+++ New post', post.title, post.link)
						-- irc.client:send("PRIVMSG #leafo :New Post [ "..post.title.." ] [ "..post.link.." ]\r\n")
						irc:me(irc:color(colors.red, 'New post')..
							irc:color(colors.green, " [ ")..post.title..irc:color(colors.green," ] [ ")..
							post.link..irc:color(colors.green, " ]").."\r\n")
					end
				end
				self.last_date = posts[1].date
			end)
			return true
		end
	}
}


local listening = {}
local readers = {}
local responders = {}

function add_listener(client, reader, responder)
	table.insert(listening, client)
	readers[client] = coroutine.create(reader(client))
	responders[client] = responder
end

function remove_listener(client)
	-- print('+++ Removing listener')
	client:close()
	readers[client] = nil
	local ir = nil
	for i,v in ipairs(listening) do
		if v == client then
			ir = i
			break
		end
	end
	table.remove(listening, ir)
end

local function Irc(sck)
	return {
		client = sck,
		channels = {},
		message = function(self, msg)
			for _,channel in ipairs(self.channels) do
				sck:send('PRIVMSG '..channel..' :'..msg..'\r\n')
			end
		end,
		message_to = function(self, who, msg)
			sck:send('PRIVMSG '..who..' :'..msg..'\r\n')
		end,
		me = function(self, msg)
			local delim = string.char(0x01)
			self:message(table.concat({delim, 'ACTION ', msg, delim}))
		end,
		join = function(self, channel)
			sck:send("JOIN "..channel.."\r\n")
			table.insert(self.channels, channel)
		end,
		color = function(self, color, msg) 
			local delim = string.char(0x03)
			return table.concat({delim, color, msg, delim})
		end
	}
end

add_listener(client, command_reader, command_responder)

local time = socket.gettime()
local irc = Irc(client)
while true do
	local readable, writeable, err = socket.select(listening, nil, 1)
	if err ~= 'timeout' then
		for _, socket in ipairs(readable) do
			local co = readers[socket]
			local result = {coroutine.resume(co)}
			local success = table.remove(result, 1)

			if not success then
				error(unpack(result)) -- just remove the thread
			end

			if #result > 0 and responders[socket] then
				responders[socket](socket, unpack(result))
			end

			if coroutine.status(co) == 'dead' then
				remove_listener(socket)
			end
		end
	end

	-- run any outstanding tasks
	local new_time = socket.gettime()
	local elapsed = new_time - time
	time = new_time

	local completed = {}
	for i, task in ipairs(tasks) do
		task.elapsed = (task.elapsed or 0) + elapsed
		if task.elapsed >= task.time then
			-- print("+++ Running task", task.name)
			if not task:run(irc) then table.insert(completed, i) end
			task.elapsed = 0
		end
	end

	for _,i in ipairs(completed) do table.remove(tasks, i) end
end

client:close()

