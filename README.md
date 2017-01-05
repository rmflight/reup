# reup

The goal of reup is to provide sane ways to install a new `R` library based on
old one.

It is inspired from [this](https://gist.github.com/rmflight/f3d6d1982e707350606e)
simple `R` script that was intended for purely personal use.

## Installation

You can install reup from github with:

```R
# install.packages("devtools")
devtools::install_github("rmflight/reup")
```

## Using reup

`reup` is a package for re-installing a bunch of `R` packages from one library
location to a new one, in a way that is automatic, and will hopefully introduce
few errors. It assumes that packages are being installed from `R` itself, not
from the OS command line. This essentially means source packages in Linux, and
normally binary packages on Windows and Mac. 

It is opinionated in how it expects the library location to be
defined, in that the local library for installing things is defined
by the `.Renviron` file, with the environment variable `R_LIBS` is set. For example,
this might be something like:

```
R_LIBS=/home/user/R_libs/R322_libs
```

This is used by `R` to set the entries in `.libPaths()`.

### Set New Library Location

Before installing the new version of `R`, you should install `reup` (see instructions
above), and run:

```R
library(reup)
set_new_library()
```

In all of the following examples, I am going to assume that the old library location
is in `/home/user/R_libs/old_libs`, and the new one is in `/home/user/R_libs/new_libs`.

### Modify .Renviron

```
R_LIBS=/home/user/R_libs/new_libs
```

### Restart R

Now you can restart `R`, and verify that the new library is the default, and that
only the base packages are installed.

```R
.libPaths()
installed.packages()
```

### Install reup (again)

Oddly enough, to use it, you need to install it again. Currently this requires
`devtools` so that one can install from github.

```R
install.packages("devtools")
devtools::install_github("rmflight/reup")
```

### Installing Local Packages

If you want to be able to install local packages, you will also **need** `devtools`
installed.

### Define Old and New Library

```R
library(reup)
set_old_library("~/R_libs/old_libs")
set_new_library("~/R_libs/new_libs")
```

### Define Mirrors

```R
set_cran_mirror()
set_bioc_mirror() # exclude if you don't have any bioconductor packages
```

### Install Packages

```R
reup()
```


## Code Of Conduct

Please note that this project is released with a [Contributor Code of Conduct](CONDUCT.md). By participating in this project you agree to abide by its terms.
