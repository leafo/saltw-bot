require "sitegen"
tools = require "sitegen.tools"

site = sitegen.create_site =>
  deploy_to "leaf@leafo.net", "www/saltw"

  add "index.html"

  scssphp = tools.system_command "pscss < %s > %s", "css"
  coffeescript = tools.system_command "coffee -c -s < %s > %s", "js"

  build scssphp, "style.scss"
  build coffeescript, "index.coffee"
