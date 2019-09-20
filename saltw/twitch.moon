
find_tag = (tags, name) ->
  return unless tags
  for tag in *tags
    if tag.key == name
      return tag.value


{:find_tag}
