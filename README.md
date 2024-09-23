# Kamp-2024-Broiler-Litter
Data and analysis from study on emissions of NH3 and GHGs from broiler litter. 

# Maintainer
Jesper Nørlem Kamp.
Contact information here: <https://au.dk/jk@bce.au.dk>.

# Contributors
Jesper Nørlem Kamp <https://au.dk/jk@bce.au.dk>

Anders Feilberg <https://au.dk/af@bce.au.dk>

# Submitted paper
The contents of this repo are presented in the following manuscript:

Kamp, J., N., Feilberg, A. Ammonia, methane, and nitrous oxide emissions from stockpiled broiler litter

# Overview
This repo contains data and data processing scripts needed to produce the results presented in the paper listed above.
The scripts run in MATLAB R2023b and require several add-on packages.

# Directory structure

## `Calc`
`MAPI2023.m` is used to produce figures.
`stats_table.xlxs` is used for `Figure 4`.

## `Manure analysis`
`Analysis.xlxs` contains laboratory results from manure analysis.

## `MAT files`
.mat files with data files used by script `MAPI2023.m`to produce figures and tables.

# Links to paper
This section give the sources of tables and figures presented in the paper.

**Figure 2** is generated with MATLAB, see script `MAPI2023.m` Line 112.

**Figure 3** is generated with MATLAB, see script `MAPI2023.m` Line 208.

**Figure 4** is generated with MATLAB, see script `MAPI2023.m` Line 154.

**Table 1** see `Manure analysis\Analysis.xlxs`.

**Table 2** is generated with data from MATLAB, see script `MAPI2023.m` Line 62. See also `stats_table.xlxs` where the table is shown. 

**Table 3** see `stats_table.xlxs`. 
