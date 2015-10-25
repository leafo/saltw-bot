
import decode_html_entities from require "saltw.util"

class UrlTitles extends require "saltw.extension"
  new: (@irc) =>
    @irc\on "irc.message", @\message_handler

  message_handler: (e, irc, name, chan, msg) =>
    url = msg\match "%f[%a]https?://[^%s]+"
    return unless url

    irc.event_loop\http_get url, (body) ->
      return unless body
      title_patt = "[tT][iI][tT][lL][eE]"
      title = body\match("<#{title_patt}>(.-)</#{title_patt}>")

      return unless title

      irc\me {
        irc\color "grey", "[Title]"
        " "
        decode_html_entities(title)
      }, chan

