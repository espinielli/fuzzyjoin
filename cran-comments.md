## Bug fixes

* Added `interval_join`, which joins tables on cases where (start, end) intervals overlap between the two columns. This adds IRanges from Bioconductor to SUGGESTS.
* Added `genome_join`, which is a more specific case of `interval_join` that joins tables on based on (chromosome, start, end), where the chromosome must agree and (start, end) must overlap.
* Added `index_match_fun` argument to `fuzzy_join`, which handles functions (such as `interval_join` and `genome_join`) that operate on the original columns rather than all pairs of columns
* Added `ignore_case` option to `regex_join` (thanks to Abraham Neuwirth; #26)
* Fixed bug when matching multiple columns to the same column (#28)
* Fixed bug in which rows were sometimes duplicated when no distance column was specified (#21)
* Added more unit tests

## Package management

* Updated README for newest versions of dplyr and janeaustenr

## Test environments

* local OS X install, R 3.4.0
* win-builder (devel and release)

## R CMD check results

There were no ERRORs, WARNINGs or NOTEs.

## Reverse dependencies

There are currently no reverse dependencies in CRAN.
