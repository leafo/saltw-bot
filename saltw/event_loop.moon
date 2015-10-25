
import insert, remove from table

socket = require "socket"

-- non blocking event loop
class EventLoop
  new: =>
    @listening = {}
    @readers = {}
    @tasks = {}

  -- task = {
  --   name: "The Name"
  --   interval: 4 -- how many seconds between each re-run, nil to run once
  --   time: 10 -- time in seconds until next run
  --   action: -> -- the function
  -- }
  add_task: (task) =>
    insert @tasks, task
    task

  add_listener: (reader) =>
    sock = reader.socket
    fn = reader\make_coroutine!
    err_handler = reader\handle_error

    @readers[sock] = { fn, err_handler }
    insert @listening, sock

  remove_listener: (client) =>
    client\close!
    @readers[client] = nil
    @listening = [sock for sock in *@listening when sock != client]

  http_get: (...) =>
    import HTTPRequest from require "saltw.socket"
    @add_listener HTTPRequest\get ...

  run: =>
    last_time = socket.gettime!
    while true
      readable, writable, err = socket.select @listening, nil, 0.5
      if err ~= "timeout"
        for sock in *readable
          co, err_handler = unpack @readers[sock]
          result = { coroutine.resume co }
          success = remove result, 1
          error unpack result unless success

          if result[1] != nil
            err_handler unpack result
            @remove_listener sock
          elseif coroutine.status(co) == "dead"
            @remove_listener sock

      -- run the tasks
      time = socket.gettime!
      dt = time - last_time
      last_time = time

      @tasks = for task in *@tasks
        task.time = (task.time or task.interval or 0) - dt
        if task.time < 0
          -- print "++ Running task: #{task} #{task.name} #{task.interval} #{task.time}"
          task\action!
          if task.interval
            task.time += task.interval
            task
          else
            continue -- remove the task
        else
          task

{ :EventLoop }
