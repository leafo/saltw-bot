
import utf8 from require "unicode"

entities = { amp: '&', gt: '>', lt: '<', quot: '"', apos: "'" }

decode_html_entities = (str) ->
  (str\gsub '&(.-);', (tag) ->
    if entities[tag]
      entities[tag]
    elseif chr = tag\match "#(%d+)"
      utf8.char tonumber chr
    elseif chr = tag\match "#[xX]([%da-fA-F]+)"
      utf8.char tonumber chr, 16
    else
      '&'..tag..';')

{ :decode_html_entities }
