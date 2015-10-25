import use_test_env from require "lapis.spec"
import truncate_tables from require "lapis.spec.db"

import ChannelUsers from require "saltw.models"

describe "models.streaks", ->
  use_test_env!

  before_each ->
    truncate_tables ChannelUsers

  it "logs user", ->
    ChannelUsers\log "#butt", "leafo", "Good stuff"
    ChannelUsers\log "#butt", "Leafo", "whoass"

    assert.same 1, ChannelUsers\count!
    cu = unpack ChannelUsers\select!
    assert.same "leafo", cu.name
    assert.same 2, cu.messages_count

