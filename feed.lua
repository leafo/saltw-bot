
require "lxp.lom"
-- require "util"
require "date"

module("feed", package.seeall)

function format_date(d, base)
	local diff = (base or date()) - d
	local delta = {diff:gettime()} -- h m s t
	local rows = {}
	for i, name in pairs{'hour', 'minute', 'second'} do
		if delta[i] > 0 then 
			local field = delta[i]..' '..name
			if delta[i] > 1 then field = field..'s' end
			table.insert(rows, field)
		end
	end

	return table.concat(rows, ', ')..' ago'
end

function parse(document_text, now_date_string)
	local posts = {}
	local current_post, current_tag = nil, nil

	local capture = { 'title', 'link', 'category', 'pubDate' }

	local p = lxp.new{
		StartElement = function(parser, name)
			if current_post then
				for _,tag_name in ipairs(capture) do
					if tag_name == name then
						current_tag = name
					end
				end
			end

			if name == 'item' then current_post = {} end
		end,
		CharacterData = function(parser, string)
			if current_post and current_tag then
				current_post[current_tag] = string
			end
		end,
		EndElement = function(parser, name) 
			if name == 'item' then
				local now = now_date_string and date(now_date_string) or date()
				current_post.date = date(current_post.pubDate)
				current_post.pretty_date = format_date(current_post.date, now)

				table.insert(posts, current_post)
				current_post = nil
			elseif current_tag == name then
				current_tag = nil
			end

		end
	}

	p:parse(document_text)
	p:close()

	return posts
end

-- print(dump(parse(io.open('out.xml'):read('*a'))))

