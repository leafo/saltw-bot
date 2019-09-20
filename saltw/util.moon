
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


bind = (obj, method_name) ->
  (...) -> obj[method_name] obj, ...

print_error = (header, err, trace) ->
  colors = require "ansicolors"

  colors = require "ansicolors"
  print ""
  print colors "%{bright}%{red}#{header}"
  print colors.noReset"%{yellow}" ..  err .. colors"%{reset}"
  if trace
    print trace
  print ""

safe_call = (header, fn) ->
  local err, trace

  success = xpcall fn, (_err) ->
    err = _err
    trace = debug.traceback "", 2

  unless success
    print_error header, err, trace

{ :decode_html_entities, :bind, :print_error, :safe_call }
