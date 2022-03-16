<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Stats</title>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <link rel="stylesheet" href="style.css">
    <script>
      const getCellValue = (tr, i) => tr.children[i].innerText || tr.children[i].textContent;
      const compare = (a, b) => a !== '' && b !== '' && !isNaN(a) && !isNaN(b) ? a - b : a.toString().localeCompare(b);
      const compareCol = (i, asc) => (a, b) => compare(getCellValue(asc ? a : b, i), getCellValue(asc ? b : a, i));
      window.onload = () => {
          const tables = document.querySelectorAll('table');
          tables.forEach(table => {
              const ths = table.rows[0].cells;
              const cols = ths.length;
              var bestCells = new Array(cols).fill([]);
              var bestVals = new Array(cols).fill(null);
              var comparers = new Array(cols).fill(null);
              for (var i = 0, th; th = ths[i]; i++) {
                  switch (th.getAttribute('best')) {
                  case 'max':
                      bestVals[i] = Number.MIN_VALUE;
                      comparers[i] = (a, b) => a > b;
                      break;
                  case 'min':
                      bestVals[i] = Number.MAX_VALUE;
                      comparers[i] = (a, b) => a < b;
                      break;
                  }                   
              }
              for (var i = 0, row; row = table.rows[i+1] /* ignore header row */; i++) {
                  for (var j = 0, col; col = row.cells[j]; j++) {
                      const comparer = comparers[j];
                      const max = bestVals[j];
                      const val = parseFloat(col.innerText);
                      if (comparer == null) {
                          continue
                      }
                      if (comparer(val, max)) {
                          bestVals[j] = val;
                          bestCells[j] = [col];
                      } else if (val == max) {
                          bestCells[j].push(col);
                      }
                  }
              }
              bestCells.forEach(col => col.forEach(td => td.classList.add('best')));
          });
          
          document.querySelectorAll('th').forEach(th => th.addEventListener('click', (() => {
              const table = th.closest('table');
              Array.from(table.querySelectorAll('tr:nth-child(n+2)'))
                  .sort(compareCol(Array.from(th.parentNode.children).indexOf(th), this.asc = !this.asc))
                  .forEach(tr => table.appendChild(tr) );
          })));
      };
    </script>
  </head>
  <body>
    <h1>Primary stats</h1>
    <table id="primary-stats">
      <tr>
        <th best="none">Name</th>
        <th title="Games played" best="max">Games</th>
        <th title="Games won" best="max">Wins</th>
        <th title="Games drawn" best="max">Draws</th>
        <th title="Games lost" best="min">Losses</th>
        <th title="Ratio of wins" best="max">Win ratio</th>
        <th title="Goals scored whilst outfield" best="max">Goals</th>
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
