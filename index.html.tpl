<!DOCTYPE html>
<html lang="en">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="style.css">
    <title>Wednesday night football</title>
  </head>
  <body>
    <h1>Wednesday night football</h1>
    <h2><a href='./stats.html'>Stats</a></h2>
    <h2>Match reports</h2>
    {{ range . }}
    <h3><a href='{{ .Path }}'>{{ .Title }}</a></h3>
    {{ end }}
  </body>
</html>
