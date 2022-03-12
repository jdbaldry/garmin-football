<!DOCTYPE html>
<html>
  <head>
    <title>{{ .MatchReport.Date }} {{ .MatchReport.A.Captain }} vs. {{ .MatchReport.B.Captain }}</title>
    <script>
      const getCellValue = (tr, i) => tr.children[i].innerText || tr.children[i].textContent;
      const compare = (a, b) => a !== '' && b !== '' && !isNaN(a) && !isNaN(b) ? a - b : a.toString().localeCompare(b);
      const compareCol = (i, desc) => (a, b) => compare(getCellValue(desc ? b : a, i), getCellValue(desc ? a : b, i));

      window.onload = () => {
          document.querySelectorAll('th').forEach(th => th.addEventListener('click', (() => {
              const table = th.closest('table');
              Array.from(table.querySelectorAll('tr:nth-child(n+2)'))
                  .sort(compareCol(Array.from(th.parentNode.children).indexOf(th), this.desc = !this.desc))
                  .forEach(tr => table.appendChild(tr) );
          })));
      };
    </script>
    <style>
      div { text-align: center; width: 100%; }
      table,td,th { border: 1px solid; }
      table { cell-padding: 0; cell-spacing: 10; width: 100%; }
      th { cursor: pointer; }
      .black { background: black; color: white; }
      .team { background: white; float: left; text-align: center; width: 50%; }
      .result { font-size: xx-large; }
      .minute { width: 20%; }
      .type { width: 40%; }
      .player { width: 40%; }
      .Keeper { background: blue; color: white; float: left; }
      .Goal { background: green; color: white; float: left; }
      .Own { background: purple; color: white; float: left; }
      .Yellow { background: yellow; float: left; }
      .Red { background: red; color: white; float: left; }
      .Kickoff,.Paused,.Full { background: grey; color: white; }
    </style>
  </head>
  <body>
    <h1 align="center">{{ .MatchReport.Date }} {{ .MatchReport.A.Captain }} vs. {{ .MatchReport.B.Captain }}</h1>
    <div class="black">Result</div>
    <div class="result">
      {{ printf "%02d" .MatchReport.A.Score }} - {{ printf "%02d" .MatchReport.B.Score }}
    </div>
    <div class="black">Players</div>
    <div>
      <div class="team">
        <table>
          <tr>
            <th>Player</th>
            <th>Goals</th>
            <th>Conceded</th>
            <th>Own goals</th>
            <th>Yellows</th>
            <th>Reds</th>
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
      <div class="team">
        <table>
          <tr>
            <th>Player</th>
            <th>Goals</th>
            <th>Conceded</th>
            <th>Own goals</th>
            <th>Yellows</th>
            <th>Reds</th>
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
    <div class="black">Events</div>
    <div>
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
      <div align="center" class="{{ .Type }}">{{ printf "%.0f" .Minute }}' {{ .Type }}</div>
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
        <div align="center" class="player {{ .Type }}">{{ .Player }}</div>
       </div>
      {{ end }}
      {{ end }}
      {{ end }}
    </div>
  </body>
</html>
