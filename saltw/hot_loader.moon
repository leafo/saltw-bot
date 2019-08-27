
inotify = require "inotify"
bit = require "bit"
cqueues = require "cqueues"

class HotLoader
  new: =>
    @wds = {}

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

  on_file_modified: (full_path, event) =>
    print "modified a file", full_path, event.mask

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

      -- require("moon").p {
      --   :is_create_dir
      --   :event
      -- }

      path = @wds[event.wd]
      full_path = "#{path}/#{event.name}"

      if is_create_dir
        @watch_dir full_path

      if is_edit_file
        @on_file_modified full_path, event


