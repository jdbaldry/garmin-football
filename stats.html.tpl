<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Stats</title>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="style.css">
    <script type="text/javascript" src="table.js"></script>
  </head>
  <body>
    <h1>Primary stats</h1>
    <table id="primary-stats">
      <tr>
        <th best="none">Name</th>
        <th title="Games played" best="max">P</th>
        <th title="Games won" best="max">W</th>
        <th title="Games drawn" best="max">D</th>
        <th title="Games lost" best="min">L</th>
        <th title="Ratio of wins" best="max">Win ratio</th>
        <th title="Goals scored whilst outfield" best="max">G</th>
        <th title="Goals per hour played outfield" best="max">GPH</th>
      </tr>
      {{ range $player, $stats :=  . }}
      <tr>
        <td>{{ $player }}</td>
        <td>{{ $stats.Games }}</td>
        <td>{{ $stats.Wins }}</td>
        <td>{{ $stats.Draws }}</td>
        <td>{{ $stats.Losses }}</td>
        <td>{{ printf "%.2f" $stats.WinRatio }}</td>
        <td>{{ $stats.Goals }}</td>
        <td>{{ printf "%.2f" $stats.GPH }}</td>
      </tr>
      {{ end }}
    </table>
    <h1>Secondary stats</h1>
    <table>
      <tr>
        <th>Name</th>
        <th title="Time spent outfield">Outfield</th>
        <th title="Time spent in goal">In goal</th>
        <th title="Goals conceded whilst in goal">Conceded</th>
        <th title="Own goals scored">Own goals</th>
        <th title="Yellow cards">🟨</th>
        <th title="Red cards">🟥</th>
      </tr>
      {{ range $player, $stats :=  . }}
      <tr>
        <td>{{ $player }}</td>
        <td>{{ printf "%v" $stats.Outfield }}</td>
        <td>{{ printf "%v" $stats.InGoal }}</td>
        <td>{{ $stats.Conceded }}</td>
        <td>{{ $stats.OwnGoals }}</td>
        <td>{{ $stats.YellowCards }}</td>
        <td>{{ $stats.RedCards }}</td>
      </tr>
      {{ end }}
    </table>
  </body>
</html>
