#' Print and Plot Methods for Dose–Response Meta-Regression Objects
#'
#' @description
#' S3 methods for objects of class \code{"dose"} returned by
#' \code{\link{mdcont}} and \code{\link{mdbin}}.
#'
#' \itemize{
#'   \item \code{print.dose} displays summaries of the fitted linear and/or
#'   nonlinear dose–response meta-regression models.
#'   \item \code{plot.dose} visualizes the fitted dose–response curves produced
#'   by the meta-regression models.
#' }
#'
#' @param x An object of class \code{"dose"} returned by
#' \code{\link{mdcont}} or \code{\link{mdbin}}.
#' @param model Character string specifying which model results to display.
#' Options are \code{"both"}, \code{"linear"}, or \code{"nonlinear"}.
#' @param ... Additional arguments (currently unused).
#'
#' @return
#' Both methods are called for their side effects.
#'
#' \itemize{
#'   \item \code{print.dose} prints model summaries to the console.
#'   \item \code{plot.dose} draws dose–response plots in the active graphics device.
#' }
#'
#' The original object \code{x} is returned invisibly.
#'
#' @author
#' Ahmed Abdelmageed \email{ahmedelsaeedmassad@@gmail.com}
#'
#' @seealso
#' \code{\link{mdcont}}, \code{\link{mdbin}}
#'
#' @name dose
#' @keywords methods
#'
#' @export


print.dose <- function(x, model = c("both", "linear", "nonlinear"),...) {

  model <- match.arg(model)

  if (model == "both") {
    cat("Linear Dose Response Meta Regression\n")
    cat("====================================\n")
    print(x$linear_model,...)
    cat("Non Linear Dose Response Meta Regression\n")
    cat("========================================\n")
    print(x$nonlinear_model,...)

  } else if (model == "linear") {
    cat("Linear Dose Response Meta Regression\n")
    cat("====================================\n")
    print(x$linear_model,...)

  } else if (model == "nonlinear") {
    cat("Non Linear Dose Response Meta Regression\n")
    cat("========================================\n")
    print(x$nonlinear_model,...)

  }
    invisible(x)
  }

#' @rdname dose
#' @export

plot.dose <- function(x, model = c("both", "linear", "nonlinear"),...) {

  model <- match.arg(model)

  if (model == "both") {
    cat("Linear Dose Response Meta Regression\n")
    cat("====================================\n")
    plot(x$linear_plot,...)
    cat("Non Linear Dose Response Meta Regression\n")
    cat("========================================\n")
    plot(x$nonlinear_plot,...)

  } else if (model == "linear") {
    cat("Linear Dose Response Meta Regression\n")
    cat("====================================\n")
    plot(x$linear_plot,...)

  } else if (model == "nonlinear") {
    cat("Non Linear Dose Response Meta Regression\n")
    cat("========================================\n")
    plot(x$nonlinear_plot,...)

  }
    invisible(x)
  }
