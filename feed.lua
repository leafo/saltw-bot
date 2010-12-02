
require "lxp.lom"
-- require "util"
require "date"

module("feed", package.seeall)

function insert(tbl, stack, value)
	for i,name in ipairs(stack) do
		if i == #stack then
			tbl[name] = value
		else
			if not tbl[name] then tbl[name] = {} end
			tbl = tbl[name]
		end
	end
end

function find(table, name) 
	for i,iname in ipairs(table) do
		if name == iname then return i end
	end
	return nil
end

function top(table)
	return table[#table]
end

function parse(document_text, now_date_string)
	local posts = {}
	local current_post, tag_stack = nil, {}

	local item_tag = 'recent-post'
	local capture = {
		'subject', 'link', 'date', 'time',
		poster = { 'name', 'link' },
	}

	local p = lxp.new{
		StartElement = function(parser, name)
			if name == item_tag then
				current_post = {}
			elseif current_post then
				if capture[name] then
					capture[name].__root = capture
					capture = capture[name]
				else 
					local id = find(capture, name)
					if not id then
						capture = { __root = capture }
					end
				end
				table.insert(tag_stack, name)
				-- print(table.concat(tag_stack, ' -> '))
			end
		end,
		CharacterData = function(parse, string)
			local id = find(capture, top(tag_stack))
			if id then
				insert(current_post, tag_stack, string)
			end
		end,
		EndElement = function(parser, name)
			if current_post then
				if name == item_tag then
					table.insert(posts, current_post)
					current_post = nil
				else
					if not find(capture, name) then
						capture = capture.__root
					end
				end
				table.remove(tag_stack)
			end
		end
	}

	p:parse(document_text)
	p:close()

	for _,post in ipairs(posts) do
		local time = post.time:match('Today at (.*)')
		if time then
			post.time = date(date():fmt('%F ')..time)
		else
			post.time = date(post.time)
		end

		-- shorten the link
		local mid = post.link:match('#msg(%d+)')
		if mid then
			post.link = 'http://saltw.net/msg'..mid
		end

	end

	return posts
end

-- print(dump(parse(io.open('out3.xml'):read('*a'))))
