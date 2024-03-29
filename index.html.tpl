<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../style.css">
    <title>{{ .Day }} night football</title>
  </head>
  <body>
    <h1>{{ .Day }} night football</h1>
    {{ if eq .Day "Wednesday" }}<h2><a href='./2022/index.html'>2022</a></h2>{{ end }}
    <h2><a href='./stats.html'>Current stats</a></h2>
    <h2>Current match reports</h2>
    {{ range .Pages }}
    <h3><a href='{{ .Path }}'>{{ .Title }}</a></h3>
    {{ end }}
  </body>
</html>
