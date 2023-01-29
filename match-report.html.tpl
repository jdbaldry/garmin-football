<!DOCTYPE html>
<html lang="en">
  <head>
    <title>{{ .MatchReport.Date }} {{ .MatchReport.A.Captain }} vs. {{ .MatchReport.B.Captain }}</title>

    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="../style.css">
    <link rel="script" href="">
    <script type="text/javascript" src="../table.js"></script>
  </head>
  <body>
    <h1 align="center">{{ .MatchReport.Date }} {{ .MatchReport.A.Captain }} vs. {{ .MatchReport.B.Captain }}</h1>
    <div>
      <div class="team">{{ if ne .MatchReport.Prev "" }}<a href={{ .MatchReport.Prev }}>Previous</a>{{ else }}&nbsp{{ end }}</div>
      <div class="team">{{ if ne .MatchReport.Next "" }}<a href={{ .MatchReport.Next }}>Next</a>{{ else }}&nbsp{{ end }}</div>
    </div>
    <div>
      <h2 class="black">Result</h2>
    </div>
    <div class="result">
      {{ printf "%02d" .MatchReport.A.Score }} - {{ printf "%02d" .MatchReport.B.Score }}
    </div>
    <div>
      <h2 class="black">Players</h2>
      <div class="team table">
        <table>
          <tr>
            <th>Player</th>
            <th best="max">Goals</th>
            <th {{- if gt .MatchReport.Date "2022-03-17" }} best="min"{{- end -}}>Conceded</th>
            <th>Own goals</th>
            <th>🟨</th>
            <th>🟥</th>
          </tr>
          {{ $sr := .StatsReport.A }}
          {{ $mr := .MatchReport.A }}
          {{ range $i, $a := .MatchReport.A.Players }}
          {{ with (index $sr $a) }}
          <tr>
            <td>{{ $a }}{{ if eq $mr.Captain $a }}*{{ end }}</td>
            <td>{{ .Goals }}</td>
            <td>{{ .Conceded }}</td>
            <td>{{ .OwnGoals }}</td>
            <td>{{ .YellowCards }}</td>
            <td>{{ .RedCards }}</td>
          </tr>
          {{ end }}
          {{ end }}
        </table>
      </div>
      <div class="team table">
        <table>
          <tr>
            <th>Player</th>
            <th best="max">Goals</th>
            <th {{- if gt .MatchReport.Date "2022-03-17" }} best="min"{{- end -}}>Conceded</th>
            <th>Own goals</th>
            <th>🟨</th>
            <th>🟥</th>
          </tr>
          {{ $mr := .MatchReport.B }}
          {{ $sr := .StatsReport.B }}
          {{ range $i, $b := .MatchReport.B.Players }}
          {{ with (index $sr $b) }}
          <tr>
            <td>{{ $b }}{{ if eq $mr.Captain $b }}*{{ end }}</td>
            <td>{{ .Goals }}</td>
            <td>{{ .Conceded }}</td>
            <td>{{ .OwnGoals }}</td>
            <td>{{ .YellowCards }}</td>
            <td>{{ .RedCards }}</td>
          </tr>
          {{ end }}
          {{ end }}
        </table>
      </div>
    </div>
    <div class="events">
      <h2 class="black">Events</h2>
      {{ range $i, $event := .MatchReport.Events }}
      {{ if eq .Team 2 }}
      {{ if eq .Type "Keeper" }}
      <div class="team">
        <div align="center" class="minute {{ .Type }}">{{ printf "%.0f" .Minute }}'</div>
        <div align="center" class="type {{ .Type }}">{{ .Type }}</div>
        <div align="center" class="player {{ .Type }}">{{ index .Players 0 }}</div>
      </div>
      <div class="team">
        <div align="center" class="minute {{ .Type }}">{{ printf "%.0f" .Minute }}'</div>
        <div align="center" class="type {{ .Type }}">{{ .Type }}</div>
        <div align="center" class="player {{ .Type }}">{{ index .Players 1 }}</div>
      </div>
      {{ else }}
      <div>
        <div align="center" class="{{ .Type }}">{{ printf "%.0f" .Minute }}' {{ .Type }}</div>
      </div>
      {{ end }}
      {{ else }}
      {{ if eq .Team 0 }}
      <div class="team">
        <div align="center" class="minute {{ .Type }}">{{ printf "%.0f" .Minute }}'</div>
        <div align="center" class="type {{ .Type }}">{{ .Type }}</div>
        <div align="center" class="player {{ .Type }}">{{ .Player }}</div>
      </div>
      <div class="team">&nbsp</div>
      {{ else }}
      <div class="team">&nbsp</div>
      <div class="team">
        <div align="center" class="minute {{ .Type }}">{{ printf "%.0f" .Minute }}'</div>
        <div align="center" class="type {{ .Type }}">{{ .Type }}</div>
        <div align="center" class="player {{ .Type }}">{{ .Player }}</div>       </div>
      {{ end }}
      {{ end }}
      {{ end }}
    </div>
  </body>
</html>
