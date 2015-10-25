import Dispatch from require "saltw.dispatch"

describe "saltw.dispatch", ->
  describe "structure", ->
    local d, default_structure
    before_each ->
      d = Dispatch!

      d\on "irc", 1
      d\on "irc", 2
      d\on "irc.flour", 3
      d\on "irc.flour.zone", 4

      default_structure = {
        irc: {
          1
          2
          flour: {
            3
            zone: {
              4
            }
          }
        }
      }

    it "should create a dispatch", ->
      assert.same default_structure, d.callbacks

    it "matches callbacks", ->
      assert.same {1,2}, d\callbacks_for "irc"
      assert.same {1,2}, d\callbacks_for "irc.dirt"
      assert.same {1,2,3}, d\callbacks_for "irc.flour"
      assert.same {1,2,3}, d\callbacks_for "irc.flour.more"
      assert.same {1,2,3,4}, d\callbacks_for "irc.flour.zone"
      assert.same {1,2,3,4}, d\callbacks_for "irc.flour.zone.dad"

    describe "off", ->
      it "removes entire tree", ->
        d\off "irc"
        assert.same {}, d.callbacks

      it "removes subset", ->
        d\off "irc.flour"
        assert.same {
          irc: {
            1
            2
          }
        }, d.callbacks

      it "removes nothing", ->
        d\off "irc.wowza"
        assert.same default_structure, d.callbacks

  describe "callbacks #ddd", ->
    it "runs two callbacks", ->
      out = {}

      d = Dispatch!
      d\on "cool", ->
        table.insert out, "one"

      d\on "cool", ->
        table.insert out, "two"

      d\trigger "cool"

      assert.same {"one", "two"}, out

    it "runs two cancels second callback", ->
      out = {}

      d = Dispatch!
      d\on "cool", =>
        @cancel = true
        table.insert out, "one"

      d\on "cool", =>
        table.insert out, "two"

      d\trigger "cool"

      assert.same {"one"}, out

