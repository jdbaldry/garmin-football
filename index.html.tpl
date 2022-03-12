<!DOCTYPE html>
<html>
<head>
  <title>Wednesday night football</title>
</head>
<body>
  <h1>Wednesday night football</h1>
  <div>
    <a href='./stats.html'>Stats</a>
  </div>
  <h2>Match reports</h2>
  <ul>
    {{ range . }}
    <li>
      <a href='{{ .Path }}'>{{ .Title }}</a>
    </li>
    {{ end }}
  </ul>
</body>
</html>
