This is a fix of two issues after the package has been archived on CRAN, particularly related to using SUGGESTS conditionally. My apologies. 

## Bug fixes

* Skip tests and examples for interval_join and genome_join when the IRanges package is not present
* Fixed a failing interval join test; possibly due to a IRanges behavior change.

## Test environments

* local OS X install, R 3.4.3
* win-builder (devel and release)

## R CMD check results

There were no ERRORs, WARNINGs or NOTEs.

## Reverse dependencies

There are currently no reverse dependencies in CRAN.
