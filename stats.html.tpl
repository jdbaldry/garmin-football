<!DOCTYPE html>
<html lang="en">
  <head>
    <title>Stats</title>
    <script>
      const getCellValue = (tr, i) => tr.children[i].innerText || tr.children[i].textContent;
      const compare = (a, b) => a !== '' && b !== '' && !isNaN(a) && !isNaN(b) ? a - b : a.toString().localeCompare(b);
      const compareCol = (i, asc) => (a, b) => compare(getCellValue(asc ? a : b, i), getCellValue(asc ? b : a, i));

      window.onload = () => {
          document.querySelectorAll('th').forEach(th => th.addEventListener('click', (() => {
              const table = th.closest('table');
              console.log("here");
              Array.from(table.querySelectorAll('tr:nth-child(n+2)'))
                  .sort(compareCol(Array.from(th.parentNode.children).indexOf(th), this.asc = !this.asc))
                  .forEach(tr => table.appendChild(tr) );
          })));
      };
    </script>
    <style>
      table, th, td { border: 1px solid black; }
      th { cursor: pointer; }
    </style>
  </head>
  <body>
    <table>
      <tr>
        <th>Name</th>
        <th>Games</th>
        <th>Wins</th>
        <th>Draws</th>
        <th>Losses</th>
        <th>Win ratio</th>
        <th>Outfield</th>
        <th>In goal</th>
        <th>Goals</th>
        <th>Goals per game</th>
        <th>Goals per hour</th>
        <th>Conceded</th>
        <th>Conceded per game</th>
        <th>Conceded per hour</th>
        <th>Own goals</th>
        <th>Own goals per game</th>
        <th>Own goals per hour</th>
        <th>Yellows</th>
        <th>Yellows per game</th>
        <th>Reds</th>
        <th>Reds per game</th>
      </tr>
      {{ range $player, $stats :=  . }}
      <tr>
        <td>{{ $player }}</td>
        <td>{{ $stats.Games }}</td>
        <td>{{ $stats.Wins }}</td>
        <td>{{ $stats.Draws }}</td>
        <td>{{ $stats.Losses }}</td>
        <td>{{ printf "%.2f" $stats.WinRatio }}</td>
        <td>{{ printf "%v" $stats.Outfield }}</td>
        <td>{{ printf "%v" $stats.InGoal }}</td>
        <td>{{ $stats.Goals }}</td>
        <td>{{ printf "%.2f" $stats.GPG }}</td>
        <td>{{ printf "%.2f" $stats.GPH }}</td>
        <td>{{ $stats.Conceded }}</td>
        <td>{{ printf "%.2f" $stats.CPG }}</td>
        <td>{{ printf "%.2f" $stats.CPH }}</td>
        <td>{{ $stats.OwnGoals }}</td>
        <td>{{ printf "%.2f" $stats.OGPG }}</td>
        <td>{{ printf "%.2f" $stats.OGPH }}</td>
        <td>{{ $stats.Yellows }}</td>
        <td>{{ printf "%.2f" $stats.YPG }}</td>
        <td>{{ $stats.Reds }}</td>
        <td>{{ printf "%.2f" $stats.RPG }}</td>
      </tr>
      {{ end}}
    </table>
  </body>
</html>
