# Analysis scripts

These scripts build every derived dataset the book uses, from the original LISS
files. They are the reproducibility trail for the numbers in the text: each one
reads raw LISS data, documents the coding decisions in comments, and writes a
derived dataset **outside this repository**.

## Why the data are not here

The [LISS panel](https://www.lissdata.nl/) (Longitudinal Internet studies for
the Social Sciences, run by Centerdata, Tilburg) is free for researchers but may
not be redistributed. No LISS file, raw or derived, belongs in this repository;
`.gitignore` blocks `.dta`, `.sav` and `.rds` outright, and no such file has
ever been committed. The book still renders for everyone else because chunk
output is frozen in `_freeze/` (see [CONTRIBUTING.md](../CONTRIBUTING.md)).

## Synthetic stand-ins

Readers without LISS access can still run the chapters' code:
`synthetic/make-synthetic-liss.R` simulates, from the models fitted to the real
data, a stand-in for each of the three derived datasets with the same variable
names and types, and writes them as CSV to `../data-synthetic/`. No real row
and no identifier is copied; every number they produce differs somewhat from
the book's. `synthetic/check-synthetic-liss.R` runs the chapters' LISS chunks
on the stand-ins and prints the results next to the book's numbers.

## Getting the data

1. Register at <https://www.lissdata.nl/> and accept the conditions of use.
2. Download the studies below and unpack them.
3. Put them in a directory next to your clone of this repository:

```
parent/
├── stads-book/                          ← this repository
└── data/liss-health-social-integration/ ← LISS files and derived datasets
```

The scripts expect that layout (`../data/liss-health-social-integration/`), and
find source files whether they sit at the top of that directory or inside the
subdirectory LISS ships them in. Override the location by editing `data_dir` at
the top of a script.

| LISS study | File | Used for |
|------------|------|----------|
| Health (2025 wave) | `ch25r_EN_1.0p.dta` | BMI, hypertension, chronic conditions, self-rated health |
| Social integration and leisure (2025 wave) | `cs25r_EN_1.0p.dta` | social integration, contact frequency |
| Background variables (Jan 2025) | `avars_202501_EN_1.0p.dta` | age, gender, education |
| Health, earlier waves | via `lissr` | the longitudinal and cross-lagged models |

## The scripts

| Script | Builds | Used in |
|--------|--------|---------|
| `01-prepare-liss.R` | `liss_ch2_combined.rds` — the cross-sectional health and integration dataset | chapters 2 and 3 |
| `02-fit-liss-sem.R` | `liss-sem-output.txt`, `liss-sem-report.md` — the structural equation models | chapter 2 |
| `03-longitudinal-yang.R` | `liss_yang_longitudinal.rds` and its report — two- and three-wave Yang models | chapter 3 |
| `04-clpm-yang.R` | `liss-clpm-output.txt` — three-wave cross-lagged panel model with correlated errors | chapter 3 |
| `05-clpm-riclpm-bmi.R` | `liss_bmi_3wave8yr.rds`, `liss-clpm-riclpm-output.txt` — CLPM and RI-CLPM for BMI, 2009–2025 | chapter 3 |
| `06-prepare-lca.R` | `liss_lca_conditions.rds` — ten binary diagnosis indicators | chapter 8 |

Run them from this directory, in order, with R ≥ 4.2:

```sh
cd analysis/liss
Rscript 01-prepare-liss.R
Rscript 06-prepare-lca.R      # and so on
```

The `.txt` and `.md` files beside the scripts are their saved output, committed
so that the fitted results can be inspected without re-running anything.

The longitudinal scripts use [`lissr`](https://github.com/daob/lissr) to pull
waves from a local LISS archive; point it at yours with the `LISS_ARCHIVE`
environment variable.
