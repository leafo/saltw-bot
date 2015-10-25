
describe "saltw.util", ->
  import decode_html_entities from require "saltw.util"

  strings = {
    {"Welcome&#33;", "Welcome!"}
    {"&#x41;", "A"}
    {"When it&#8217;s a new Torment game", "When it’s a new Torment game"}
  }

  for {str, expected} in *strings
    it "decodes html entites", ->
      assert.same expected, decode_html_entities str


