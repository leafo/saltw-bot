
import utf8 from require "unicode"

export get_config = (package_name, default) ->
  initial = false
  if not package.loaded[package_name]
    success, cfg = pcall require, package_name
    if success
      setmetatable cfg, __index: default
      package.loaded.config = cfg
    else
      print "+++ Failed to load config:", package_name
      package.loaded.config = default

  package.loaded.config

entities = { amp: '&', gt: '>', lt: '<', quot: '"', apos: "'" }

export decode_html_entities = (str) ->
  (str\gsub '&(.-);', (tag) ->
    if entities[tag]
      entities[tag]
    elseif chr = tag\match "#(%d+)"
      utf8.char tonumber chr
    elseif chr = tag\match "#[xX](%d+)"
      utf8.char tonumber chr, 16
    else
      '&'..tag..';')

if ... == "test"
  print decode_html_entities "Welcome&#33;"
  print decode_html_entities "&#x41;"
  print decode_html_entities "When it&#8217;s a new Torment game"
