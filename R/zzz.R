#' @importFrom rjd3toolkit get_java_version minimal_java_version
.onAttach <- function(libname, pkgname) {
    if (rjd3toolkit::get_java_version() < rjd3toolkit::minimal_java_version) {
        packageStartupMessage(sprintf(
            "Your java version is %s. %s or higher is needed.",
            rjd3toolkit::get_java_version(),
            rjd3toolkit::minimal_java_version
        ))
    }
}

#' @importFrom rjd3toolkit get_java_version minimal_java_version
#' @importFrom rJava .jpackage .jcall .jaddClassPath
.onLoad <- function(libname, pkgname) {
    jar_dir <- file.path(libname, pkgname, "inst", "java")
    jars <- list.files(jar_dir, pattern = "\\.jar$", full.names = TRUE, all.files = TRUE)
    rJava::.jaddClassPath(jars)
    result <- rJava::.jpackage(pkgname, lib.loc = libname)
    if (!result) stop("Loading java packages failed", call. = FALSE)

    if (rjd3toolkit::get_java_version() >= rjd3toolkit::minimal_java_version) {
        # Reload extractors
        try({
            rJava::.jcall(
                obj = "jdplus/toolkit/base/api/information/InformationExtractors",
                returnSig = "V",
                method = "reloadExtractors"
            )
        })
    }
}
