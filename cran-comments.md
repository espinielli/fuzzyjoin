## Features

* Added option not only to join based on a maximum distance but also to append a distance column, using the `distance_col` argument. This is available in `difference_join`, `distance_join`, `stringdist_join`, and `geo_join` (#10)

## Bug fixes

* Fixed to ignore groups while preserving the groups of x in the output (#11)
* Fixed to append `.x` and `.y` to all common columns, not just those in `by` (#12)

## Package management

* Added codecov to measure test coverage
* Added AppVeyor continuous integration
* Added Code of Conduct

## Test environments

* local OS X install, R 3.3.0
* win-builder (devel and release)

## R CMD check results

There were no ERRORs, WARNINGs or NOTEs.

## Reverse dependencies

There are currently no reverse dependencies in CRAN.
