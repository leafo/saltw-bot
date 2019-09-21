
sign = (num) ->
  num < 0 and -1 or 1

priority = 0

class Player
  x: 0
  y: 0
  score: 0

  w: 50
  h: 50

  scale: 1

  speed: 400
  step: 150
  color: { 1, 0.6, 0.6 }

  new: (@name, @game) =>
    @movements = {}

  update: (dt) =>
    if next @movements
      current = @movements[1]

      dx = dt * @speed * sign current[1]

      if dx < 0
        dx = math.max current[1], dx
      else
        dx = math.min current[1], dx

      dy = dt * @speed * sign current[2]

      if dy < 0
        dy = math.max current[2], dy
      else
        dy = math.min current[2], dy

      current[1] -= dx
      current[2] -= dy

      if current[1] == 0 and current[2] == 0
        table.remove @movements, 1

      @x += dx
      @y += dy

      @x = math.max 0, @x
      @y = math.max 0, @y

      @x = math.min love.graphics.getWidth() - @w, @x
      @y = math.min love.graphics.getHeight() - @h, @y

      --- check for collision
      for other in *@game\all_players!
        continue if other == @
        if @touches other
          print "is attacker?", @is_attacker other, current[3]
          if @is_attacker other, current[3]
            print @name, "is attacking", other.name
            @score += 1
            @game\end_round @

  is_attacker: (other, priority) =>
    if next other.movements
      priority < other.movements[1][3]
    else
      true

  draw: =>
    love.graphics.setColor unpack @color
    love.graphics.push()
    love.graphics.translate @x + @w / 2, @y + @h / 2
    love.graphics.scale @scale, @scale

    love.graphics.rectangle "fill",
      -@w / 2,
      -@h / 2,
      @w,
      @h

    love.graphics.pop()

    if @ == @game\get_next_team_player!

      love.graphics.setColor 1,1,1
      love.graphics.rectangle "fill",
        @x + @w * 3/4 + 2,
        @y + @h * 3/4 + 2,
        @w / 4,
        @h / 4

      love.graphics.setColor 0,0,0
      love.graphics.rectangle "fill",
        @x + @w * 3/4 ,
        @y + @h * 3/4,
        @w / 4,
        @h / 4


    @name = @name\gsub "player_", "team_"

    love.graphics.setColor 0,0,0
    love.graphics.print @name, @x, @y

    love.graphics.setColor 1,1,1
    love.graphics.print @name, @x - 1, @y - 1

  clear_movements: =>
    @movements = {}

  move: (dx=0, dy=0) =>
    print ">>> moving #{@name}"
    @movements or= {}
    priority += 1

    table.insert @movements, {
      dx * @step, dy * @step, priority
    }

  touches: (other_player) =>
    if @x > other_player.x + other_player.w
      return false

    if @x + @w < other_player.x
      return false

    if @y > other_player.y + other_player.h
      return false

    if @y + @h < other_player.y
      return false

    true


    
