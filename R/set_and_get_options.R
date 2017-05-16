#' set cran mirror
#'
#' Sets the CRAN mirror to use. Default is the RStudio one
#'
#' @param url the url of the CRAN mirror
#'
#' @export
#' @return NULL
set_cran_mirror <- function(url = "https://cloud.r-project.org/"){
  assign("cran_mirror", url, envir = reup_options)
}

get_cran_mirror <- function(){
  get("cran_mirror", envir = reup_options)
}

#' set bioconductor mirror
#'
#' Sets the Bioconductor mirror to use. Default is https://bioconductor.org
#'
#' @export
#' @return NULL
set_bioc_mirror <- function(url = "https://bioconductor.org"){
  assign("bioc_mirror", url, envir = reup_options)
}

get_bioc_mirror <- function(){
  reup:::reup_options$bioc_mirror
}

#' old library location
#'
#' Sets the old library. Default is to take it from R_LIBS
#'
#' @param lib_loc the library location
#'
#' @export
#' @return NULL
set_old_library <- function(lib_loc = NULL){
  if (is.null(lib_loc)) {
    dir_info <- get_lib_dir_info()
    # if latest dir creation time is less than 24 hours, assume that one is
    # actually the new library, and set the old one to the next oldest
    if ((difftime(Sys.time(), dir_info[1, "mod_time"], units = "hours") < 24) && (nrow(dir_info) > 1)) {
      lib_loc <- dir_info[2, "dir"]
    } else {
      lib_loc <- dir_info[1, "dir"]
    }
  }
  assign("old_library", lib_loc, envir = reup_options)
}

get_lib_dir_info <- function(top_dir = NULL){
  if (is.null(top_dir)) {
    top_dir <- dirname(Sys.getenv("R_LIBS"))
    if (nchar(top_dir) == 0) {
      top_dir <- dirname(.libPaths[1])
    }
  }

  all_dirs <- list.dirs(top_dir, recursive = FALSE)

  dir_mod_info <- lapply(all_dirs, function(in_dir){
    dirs_in_dir <- list.dirs(in_dir, recursive = FALSE)

    if (length(dirs_in_dir) == 0) {
      out_info <- data.frame(dir = in_dir, has_dirs = "no", mod_time = NA,
                             stringsAsFactors = FALSE)
    } else {
      dir_info <- file.info(dirs_in_dir)
      out_info <- data.frame(dir = in_dir, has_dirs = "yes",
                             mod_time = max(dir_info$mtime),
                             stringsAsFactors = FALSE)
    }
    out_info
  })
  dir_info <- do.call(rbind, dir_mod_info)
  dir_info <- dir_info[!is.na(dir_info$mod_time), ]
  dir_info$mod_time <- as.POSIXct(dir_info$mod_time, origin = "1970-01-01")
  dir_info <- dir_info[order(dir_info$mod_time, decreasing = TRUE), ]
  dir_info
}

get_old_library <- function(){
  reup:::reup_options$old_library
}

#' new library location
#'
#' Creates a new library location based on the version of R, and if the
#' Bioconductor mirror is set, then the Bioconductor version as well.
#'
#' @param lib_loc the full directory name
#'
#' @export
#' @return NULL
set_new_library <- function(lib_loc = NULL){
  r_version <- R.version
  #usr_home <- Sys.getenv("HOME")
  write_message <- FALSE

  if (is.null(get_old_library())) {
    set_old_library()
    old_library <- get_old_library()
  } else {
    old_library <- get_old_library()
  }

  dir_info <- get_lib_dir_info(dirname(old_library))
  if (is.null(lib_loc)) {
    
    if ((difftime(Sys.time(), dir_info[1, "mod_time"], units = "hours") < 24) && (nrow(dir_info) > 1)) {
      lib_loc <- dir_info[1, "dir"]
    }
  }

  if (is.null(lib_loc)) {
    dir_name <- paste0("R", r_version$major, ".", r_version$minor)

    if (!is.null(get_bioc_mirror())) {
      dir_name <- paste0(dir_name, "_Bioc", tools:::.BioC_version_associated_with_R_version())
    }
    lib_loc <- file.path(dirname(get_old_library()), dir_name)
  }


  if (!dir.exists(lib_loc)) {
    dir.create(lib_loc)
    write_message <- TRUE

  } else {
    if (dir.exists(lib_loc) && (nrow(dir_info) == 1)) {
      has_numeral_end <- regexpr("_[[:digit:]]$", lib_loc)
      if (has_numeral_end != -1) {
        curr_numeral <- as.numeric(substring(lib_loc, nchar(lib_loc)))
        lib_loc <- paste0(substring(lib_loc, 1, nchar(lib_loc)-1), curr_numeral + 1)
        write_message <- TRUE
      }
    }
  }

  if (write_message) {
    message(paste0("New Library Will Be Stored In: ", lib_loc))
    message(paste0("You should add this line to your .Renviron file: \n",
                   "  R_LIBS=", lib_loc))
  }

  assign("new_library", lib_loc, envir = reup_options)

}

get_new_library <- function(){
  reup:::reup_options$new_library
}
