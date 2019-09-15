
inotify = require "inotify"
bit = require "bit"
cqueues = require "cqueues"

import types from require "tableshape"

is_class = types.shape { __base: types.table }, open: true

class HotLoader
  new: =>
    @wds = {}
    @classes_by_modules_name = setmetatable {}, {
      __index: (name) =>
        @[name] = setmetatable { }, __mode: "k"
        @[name]
    }

  add_current_dir: =>
    p = io.popen "find . -type d", "r"

    for line in p\lines!
      @watch_dir line

  watch_dir: (dir) =>
    if dir\match "^%./%."
      return

    print "Watching directory", dir
    wd = @handle\addwatch dir, inotify.IN_CLOSE_WRITE, inotify.IN_CREATE
    @wds[wd] = dir

  path_to_module: (path) =>
    unless path\match "%.moon$"
      return nil, "not moon file"

    chunks = [chunk for chunk in path\gmatch "[^/%.]+"]
    chunks[#chunks] = nil

    unless chunks[1] == "saltw"
      -- don't reload things that aren't in saltw package
      return nil, "invalid module"

    table.concat chunks, "."

  on_file_created: =>
    -- TODO: do this in the future?


  on_file_modified: (full_path, event) =>
    print "modified a file", full_path, event.mask
    module_name, err = @path_to_module full_path

    unless module_name
      return nil, err

    file = io.open full_path, "r"
    return nil, "failed to find file" unless file

    file_contents = file\read "*a"
    return nil, "failed to read file" unless file_contents

    moonscript = require "moonscript.base"
    fn, err = moonscript.loadstring file_contents
    -- TODO: handle error without crashing when there is a compile error
    return nil, err unless fn
    mod = fn!

    old_mod = package.loaded[module_name]
    return nil, "module hasn't been loaded yet" unless old_mod

    @classes_by_modules_name[module_name][old_mod] = true
    package.loaded[module_name] = mod

    -- two types of modules:
    -- 1. a class
    -- 2. a table of things, including class(es)

    if is_class(mod) and is_class(old_mod)
      -- handle as single class
      count = 0
      for old_cls in pairs @classes_by_modules_name[module_name]
        count +=1
        @reload_class old_cls, mod

      print "Reloaded #{count} class objects for #{module_name}"
    else
      -- handle each item individually..
      print "Warning: unhandled module reload"

    true

  reload_class: (old_class, new_class) =>
    old_keys = [key for key in pairs old_class.__base]
    for k in *old_keys
      old_class.__base[k] = nil

    for k, v in pairs new_class.__base
      old_class.__base[k] = v

    keys = for k,v in pairs old_class
      continue if k\match "^__"
      k

    for key in *keys
      old_class[key] = nil

    for k,v in pairs new_class
      continue if k\match "^__"
      old_class[k] = v

  start: =>
    @handle = inotify.init {
      blocking: false
    }

    @add_current_dir!

    while true
      @step_events!
      cqueues.sleep 0.1

  step_events: =>
    for event in @handle\events!
      is_create_dir_mask = bit.bor(inotify.IN_CREATE, inotify.IN_ISDIR)
      is_create_dir = bit.band(event.mask, is_create_dir_mask) == is_create_dir_mask

      is_edit_file_mask = inotify.IN_CLOSE_WRITE
      is_edit_file = bit.band(event.mask, is_edit_file_mask) == is_edit_file_mask

      if event.name == "4913"
        -- a special file written by vim that we don't care about
        continue

      path = @wds[event.wd]
      full_path = "#{path}/#{event.name}"

      if is_create_dir
        return @watch_dir full_path

      if is_edit_file
        success, err = @on_file_modified full_path, event
        unless success
          io.stderr\write "Failed to reload: #{err}\n"

        return


