# figures/

Scripts that build figures into `../images/`. Each figure has a source, a
digitizing or data-preparation step, and a plotting step, so the numbers behind
a redrawn figure can be audited rather than taken on trust.

## Ross, Campbell & Glass (1970), the British Breathalyser series

| File | What it is |
|---|---|
| `ross-1970-source.png` | The scanned original figure, three series on two y-scales |
| `ross-1970-digitize.py` | Recovers the monthly values from the scan; writes the CSV |
| `ross-1970-data.csv` | 36 months, Jan 1966 to Dec 1968, both inner-scale series |
| `ross-1970-figure.R` | Draws `../images/ross-1970-breathalyser.{png,pdf}` |

```sh
python3 figures/ross-1970-digitize.py     # scan  -> ross-1970-data.csv
Rscript  figures/ross-1970-figure.R       # csv   -> images/ross-1970-breathalyser.*
```

Requires Pillow for the first step; ggplot2, ragg, systemfonts and the Fira Sans
font for the second.

**Accuracy.** Values are read off a 557 x 622 px scan, where 100 casualties is
25 px and the drawn line is about 2 px wide, so treat them as accurate to
roughly +/- 10 casualties. The digitizer was checked by drawing the recovered
points back onto the scan; every corner of both curves is hit. Two figures worth
knowing before quoting anything: the first commuting-hours value reads 1290, and
the first weekend-night value after the Act reads 344.

**Not the published data.** These are measurements of a printed figure, not the
counts Ross and colleagues analysed. They are good enough to redraw the figure
and to reason about its shape, and they are not a substitute for the source data
if anything turns on the exact numbers.
