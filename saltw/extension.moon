cqueues = require "cqueues"

import safe_call from require "saltw.util"

class Extension
  start_cron: (delay, fn) =>
    stopped = false
    stop = -> stopped = true

    print "Starting cron: #{delay}"

    @irc.cqueues\wrap ->
      while true
        break if stopped
        cqueues.sleep delay

        safe_call "Cron job", fn

    stop

