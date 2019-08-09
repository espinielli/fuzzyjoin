# fuzzyjoin 0.1.5

The most important component of this release is that it is compatible with tidyr v1.0.0, which is planned to be submitted to CRAN on 2019-09-09. It also fixes a few minor bugs and issues.

## Features

* fuzzy_join now supports formula notation for `match_fun`, `multi_match_fun`, and `index_match_fun`.

## Bug fixes and maintenance

* Many changes to internals to make compatible with newest versions of dplyr and tidyr (#58 and #60, @jennybc)
* difference, distance, geo and stringdist joins now add a distance column even if there are no overlapping rows (fixes #57)
* distance joins now support the case where there's only one column in common (fixes #43)
* Fixed typos in documentation (#40, @ChrisMuir and #53, @brooke-watson)

## Test environments

* local OS X install, R 3.5.0
* Travis: Linux, R-devel, R-release, tidyr-devel, and R-oldrel
* AppVeyor: Windows
* win-builder (devel and release)

## R CMD check results

There were no ERRORs, WARNINGs or NOTEs.

## Reverse dependencies

There are currently three reverse dependencies: tidygenomics, xrf, and widyr. I used revdepcheck to check each with the new version of fuzzyjoin and found no problems.
