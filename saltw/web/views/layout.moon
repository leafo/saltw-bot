html = require "lapis.html"

class Layout extends html.Widget
  content: =>
    html_5 ->
      head ->
        title @title or "saltw-bot"
        meta charset: "utf-8"
        style type: "text/css", -> raw [[
          body {
            font-family: sans-serif;
            margin: 0;
          }

          a {
            color: #6277c3;
          }

          header.global_header {
            background: #99d6ff;
            color: black;
            margin: 0;
            font-size: 12px;

            display: flex;
            padding: 5px;
          }

          header.global_header a {
            color: inherit;
          }

          header.global_header a.active {
            font-weight: bold;
          }

          header.global_header h1 {
            margin: 0;
            font-size: inherit;
          }

          header.global_header nav {
            margin-left: auto;
          }

          header.global_header ul {
            list-style: none;
            padding: 0;
            margin: 0;
          }

          header.global_header li {
            display: inline-block;
            margin-right: 10px;
          }

          header.global_header li:last-child {
            margin-right: 0;
          }

          main {
            padding: 10px;
          }

          main > *:first-child {
            margin-top: 0;
          }

          table {
            border: 1px solid #dadada;
            border-collapse: collapse;
          }

          table thead td {
            font-weight: bold;
            background: #f1f1f1;
          }

          table td {
            padding: 5px;
          }
        ]]

      body ->
        header class: "global_header", ->
          h1 "saltw-bot"

          nav ->
            ul ->
              li -> @nav_link "stats", "Stats"
              li -> @nav_link "speak", "Speak"

        main ->
          @content_for "inner"

  nav_link: (route, label) =>
    a {
      href: @url_for(route)
      class: {
        active: @route_name == route
      }
    }, label
