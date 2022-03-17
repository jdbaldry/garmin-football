window.addEventListener("load", () => {
    const getCellValue = (tr, i) => tr.children[i].innerText || tr.children[i].textContent;
    const compare = (a, b) => a !== '' && b !== '' && !isNaN(a) && !isNaN(b) ? a - b : a.toString().localeCompare(b);
    const compareCol = (i, desc) => (a, b) => compare(getCellValue(desc ? b : a, i), getCellValue(desc ? a : b, i));

    document.querySelectorAll('th').forEach(th => th.addEventListener('click', (() => {
        const table = th.closest('table');
        Array.from(table.querySelectorAll('tr:nth-child(n+2)'))
            .sort(compareCol(Array.from(th.parentNode.children).indexOf(th), this.desc = !this.desc))
            .forEach(tr => table.appendChild(tr) );
    })));
});

window.addEventListener("load", () => {
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
                    continue;
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
});
