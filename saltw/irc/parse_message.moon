import S, P, R, Ct, Cg, Cs, C, Cmt from require "lpeg"

whitespace = S " \t\r\n"
whitespaces = whitespace^1

tag_key = (R("09", "az", "AZ") + S("-./+"))^1
tag_value = Cs (
  P([[\:]]) / ";" +
  P([[\s]]) / " " +
  P([[\n]]) / "\n" +
  P([[\r]]) / "\r" +
  P(1) - S("; \0\r\n")
)^0

tag = Ct Cg(tag_key, "key") * (P("=") * Cg(tag_value, "value"))^-1

tags = tag * (P(";") * tag)^0

twitch_tags = P("@") * Cg Ct(tags), "tags"

name = P(":") * Cg((P(1) - P("!"))^1, "name") * P"!" * Cg((P(1) - whitespace)^1, "host")
channel =  Cg P("#")^-1 * (P(1) - whitespace)^1, "channel"
message = P(":") * Cg P(1)^0, "message"

parser = Ct twitch_tags *
  whitespaces *
  name *
  whitespaces *
  P("PRIVMSG") *
  whitespaces *
  channel *
  whitespaces *
  message * P(-1)

parser\match
