-- connect to database
function db(dbname, user, pass) 
	require "luasql.mysql"

	local queries = {}

	local conn = assert(luasql.mysql():connect(dbname, user, pass))
	return {
		conn = conn,
		select = function(statement, ...)
			if ... then statement = statement:format(...) end
			table.insert(queries, 'select '..statement)
			local c = assert(conn:execute("select " .. statement))
			local row = {}
			local n = 0
			return function() 
				n = n + 1
				return c:fetch(row, "a"), n
			end, c:numrows()
		end,
		execute = function(query, ...)
			if ... then query = query:format(...) end
			table.insert(queries, query)
			return assert(conn:execute(query))
		end,
		escape = function(str)
			return conn:escape(tostring(str))
		end,
		serialize = function(tab)
			local out = ""
			local hit = false
			for k,v in pairs(tab) do
				hit = true
				out = out .. k .. ' = "' .. conn:escape(tostring(v)) .. '", '
			end
			if hit then out = out:sub(1,-3) end -- remove last 2 chars
			return out
		end,
		queries = function(tab) 
			if tab then queries = tab end
			return queries
		end
	}
end

-- dump variable
function dump(var, depth)
	depth = depth or 0
	if type(var) == "string" then
		return '"' .. var .. '"\n'
	elseif type(var) == "table" then
		depth = depth + 1
		out = "{\n"
		for k,v in pairs(var) do
			out = out .. (" "):rep(depth*4).. "["..tostring(k).."] = " .. dump(v, depth)
		end
		return out .. (" "):rep((depth-1)*4) .. "}\n"
	else 
		return tostring(var) .. "\n"
	end

end

function dispatch(...)
	local args = {...}
	local command = table.remove(args, 1)
	return function(routes) 
		if routes[command] then
			routes[command](unpack(args))
		else
			if not command then
				local cmds = {}
				for command in pairs(routes) do table.insert(cmds, command) end
				print('Commands: '..table.concat(cmds, ', '))
			end
			os.exit()
		end
	end
end

-- this puts the config in package.loaded.config 
-- so other files can just require "config" to get
-- the global config no matter where it came from
function get_config(package_name, default) 
	local initial = false
	if not package.loaded[package_name] then
		local success, cfg = pcall(require, package_name)
		if success then
			setmetatable(cfg, { __index = default })
			package.loaded.config = cfg
		else
			print("+++ Failed to load config:", package_name)
			package.loaded.config = default
		end
	end

	return package.loaded.config
end

