Player = require "saltw.game.player"

class Game
  time: 0

  team_users: nil

  colors: {
    { 1, 0.5, 0.5 }
    { 0.5, 1, 0.5 }
    { 0.5, 0.5, 1 }
  }

  get_player: (id) =>
    full_name = "player_#{id}"
    if p = @[full_name]
      return p

    p = Player full_name, @
    @[full_name] = p
    p.color = @colors[id % 3 + 1]
    p

  get_team: (msg) =>
    import find_tag from require "saltw.twitch"
    user_id = tonumber find_tag msg.tags, "user-id"
    team = @team_users[user_id]
    unless team
      count = 0
      for k in pairs @team_users
        count += 1

      team = count % 2 + 1
      @team_users[user_id] = team

    team

  get_next_team_player: =>
    count = 0
    for k in pairs @team_users
      count += 1

    team = count % 2 + 1
    @get_player team

  handle_message: (e, dispatch, msg) =>
    print "got message in game"
    if @round_ending
      print "but round is resetting"
      return

    team = @get_team msg
    player = @get_player team

    other_players = for i=1,2
      p = @get_player i
      continue if p == player
      p

    remaining = 3
    for command in msg.message\gmatch "(![^%s]+)"
      command = command\lower!
      print "command", command
      break if remaining == 0
      remaining -= 1

      ang = math.cos(math.pi / 4)

      switch command
        when "!dr"
          player\move ang, ang
        when "!dl"
          player\move -ang, ang
        when "!ur"
          player\move ang, -ang
        when "!ul"
          player\move -ang, -ang
        when "!down", "!d"
          player\move 0, 1
        when "!up", "!u"
          player\move 0, -1
        when "!left", "!l"
          player\move -1, 0
        when "!right", "!r"
          player\move 1, 0
        -- when "!reset"
        --   @reset_player_positions!

  all_players: =>
    return for i=1,2
      @get_player i

  end_round: (winner) =>
    return if @round_ending
    @round_ending = true
    @round_winner = winner

    for player in *@all_players!
      player\clear_movements!

    -- @reset_player_positions!
    -- @round_ending = false

  reset_player_positions: =>
    for i=1,2
      p = @get_player i
      w = love.graphics.getWidth()
      h = love.graphics.getHeight()

      p.x = w / 2 + math.cos(@time + i * math.pi) * (w / 3 + (math.random() - 0.75) * 180)
      p.y = h / 2 + math.sin(@time + i * math.pi) * (h / 3 + (math.random() - 0.75) * 180)
      p.movements = {}
      p.scale = 1

  load: =>
    @team_users = {}
    love.graphics.setFont love.graphics.newFont 18

  update: (dt) =>
    if @round_ending and @round_winner
      @round_winner.scale += dt * 3
      if @round_winner.scale > 4
        @reset_player_positions!
        @round_ending = false

    -- @irc = nil
    unless @irc
      print "!!!! adding irc", pcall ->
        @irc = require "saltw.irc.current"
        @irc\on "irc.message", (...) ->
          @handle_message ...

        @reset_player_positions!

    @time += dt

    for i=1,2
      player = @get_player i
      player\update dt

  draw: =>
    team_sizes = {}
    for k,v in pairs @team_users
      team_sizes[v] or= 0
      team_sizes[v] += 1

    for i=1,2
      player = @get_player i
      player\draw!
      love.graphics.setColor 1,1,1
      team_size = team_sizes[i] or 0

      size_label = if team_size == 0
        "empty"
      else
        "#{team_size} member#{team_size != 1 and "s" or ""}"

      love.graphics.print "#{player.name}: #{player.score} (#{size_label})", 0, (i - 1) * 20

    love.graphics.print(
      "USE COMMANDS: !up !down !left !right"
      0
      love.graphics.getHeight() - 40
      0
      2,2
    )



