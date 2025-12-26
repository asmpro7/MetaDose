#' Linear and Nonlinear Dose–Response Meta-Regression for Continuous Outcomes
#'
#' @description
#' Performs linear and/or nonlinear dose–response meta-regression for continuous
#' outcomes using study-level summary data. The function supports mean difference
#' (MD) and standardized mean difference (SMD) effect measures and fits models
#' across different dose levels using meta-regression techniques.
#'
#' @param measure Character string specifying the effect size measure.
#' Options are \code{"MD"} for mean difference or \code{"SMD"} for standardized
#' mean difference.
#' @param mean.e Numeric vector of means in the experimental group.
#' @param sd.e Numeric vector of standard deviations in the experimental group.
#' @param n.e Numeric vector of sample sizes in the experimental group.
#' @param mean.c Numeric vector of means in the control group.
#' @param sd.c Numeric vector of standard deviations in the control group.
#' @param n.c Numeric vector of sample sizes in the control group.
#' @param dose Numeric vector of dose levels corresponding to each study.
#' @param data A data frame containing the meta-analysis data.
#' @param linear Logical; if \code{TRUE}, a linear dose–response model is fitted.
#' @param nonlinear Logical; if \code{TRUE}, a nonlinear dose–response model using
#' restricted cubic splines is fitted.
#' @param x_axis Character string specifying the x-axis label for plots.
#' @param y_axis Character string specifying the y-axis label for plots.
#' @param knots Numeric vector of quantiles used to place knots for the nonlinear
#' restricted cubic spline model.
#'
#' @details
#' The function first computes effect sizes and their variances from continuous
#' outcome data. It then fits a linear dose–response meta-regression model and/or
#' a nonlinear model using restricted cubic splines, depending on user selection.
#' Corresponding dose–response plots are generated for visualization.
#'
#' @return
#' An S3 object of class `dose`, which is a list containing:
#' \item{linear_model}{The fitted linear dose–response meta-regression model.}
#' \item{linear_plot}{A plot of the linear dose–response relationship.}
#' \item{nonlinear_model}{The fitted nonlinear dose–response meta-regression model.}
#' \item{nonlinear_plot}{A plot of the nonlinear dose–response relationship.}
#'
#' @importFrom metafor escalc rma predict.rma
#' @importFrom rms rcs
#' @importFrom ggplot2 ggplot aes
#' @importFrom ggplot2 geom_ribbon geom_line geom_point
#' @importFrom ggplot2 scale_size_continuous
#' @importFrom ggplot2 labs theme_minimal theme
#' @importFrom ggplot2 element_text margin
#' @importFrom stats model.matrix quantile
#' @importFrom rlang .data
#'
#' @author
#' Ahmed Abdelmageed \email{ahmedelsaeedmassad@@gmail.com}
#'
#' @seealso
#' \code{\link{mdbin}} for dose–response meta-regression with binary outcomes.
#'
#' @export

mdcont <- function(measure = c("MD","SMD"), mean.e, sd.e, n.e,
                   mean.c, sd.c, n.c, dose, data,
                   linear = TRUE, nonlinear = TRUE,
                   x_axis = "Dose", y_axis = "Measured Effect",
                   knots = c(0.10, 0.50, 0.90)) {

  measure <- match.arg(measure)

  dose_name <- deparse(substitute(dose))

  if (!dose_name %in% names(data)) {
    stop("Column '", dose_name, "' not found in data")
  }

  names(data)[names(data) == dose_name] <- "dose"


  Calc_data <- metafor::escalc(measure = measure,
                      m1i = mean.e, sd1i = sd.e, n1i = n.e,
                      m2i = mean.c, sd2i = sd.c, n2i = n.c,
                      data = data)

  if (linear == TRUE) {

    res.lin <- metafor::rma(.data$yi, .data$vi, mods = ~ dose, data = Calc_data)

    newdose <- data.frame(dose = seq(min(Calc_data$dose), max(Calc_data$dose), length=100))

    doseModel <- metafor::predict.rma(res.lin, newmods = model.matrix(~ dose -1, data = newdose))

    doseModel_df <- data.frame(
      dose = newdose,
      pred = doseModel$pred,
      ci.lb = doseModel$ci.lb,
      ci.ub = doseModel$ci.ub)

    Calc_data$weight <- sqrt(1/Calc_data$vi)

    plot_linear <- ggplot2::ggplot() +
      ggplot2::geom_ribbon(data = doseModel_df,
                           ggplot2::aes(x = .data$dose, ymin = .data$ci.lb, ymax = .data$ci.ub),
                  fill = "#56B4E9", alpha = 0.3) +
      ggplot2::geom_line(data = doseModel_df,
                         ggplot2::aes(x = .data$dose, y = .data$pred),
                color = "#0072B2", linewidth = 1) +
      ggplot2::geom_point(data = Calc_data,
                          ggplot2::aes(x = .data$dose, y = .data$yi, size = .data$weight),
                 shape = 21, fill = "gray70", color = "black", alpha = 0.8) +
      ggplot2::scale_size_continuous(range = c(2, 8), guide = "none") +
      ggplot2::labs(x = x_axis, y = y_axis) +
      ggplot2::theme_minimal(base_size = 11) +
      ggplot2::theme(
        axis.title = ggplot2::element_text(size = 12, face = "bold"),
        axis.text = ggplot2::element_text(size = 10),
        plot.title = ggplot2::element_text(size = 14, hjust = 0.5),
        axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 10)),
        axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 10)),
        plot.margin = ggplot2::margin(5, 10, 5, 10)
      )} else {
        res.lin <- NULL
        plot_linear <- NULL
      }

  if (nonlinear == TRUE) {

    knots <- quantile(Calc_data$dose, knots)

    res.rcs <- metafor::rma(.data$yi, .data$vi, mods = ~ rms::rcs(dose, knots), data = Calc_data)

    newdose <-data.frame(dose = seq(min(Calc_data$dose), max(Calc_data$dose), length=100))


    doseModel <- metafor::predict.rma(res.rcs, newmods = model.matrix(~ rms::rcs(dose, knots) - 1, data = newdose))

    doseModel_df <- data.frame(
      dose = newdose,
      pred = doseModel$pred,
      ci.lb = doseModel$ci.lb,
      ci.ub = doseModel$ci.ub
    )

    Calc_data$weight <- sqrt(1/Calc_data$vi)

    plot_nonlinear <- ggplot2::ggplot() +
      ggplot2::geom_ribbon(data = doseModel_df,
                           ggplot2::aes(x = .data$dose, ymin = .data$ci.lb, ymax = doseModel_df$ci.ub),
                  fill = "#56B4E9", alpha = 0.3) +
      ggplot2::geom_line(data = doseModel_df,
                         ggplot2::aes(x = .data$dose, y = .data$pred),
                color = "#0072B2", linewidth = 1) +
      ggplot2::geom_point(data = Calc_data,
                          ggplot2::aes(x = .data$dose, y = .data$yi, size = .data$weight),
                 shape = 21, fill = "gray70", color = "black", alpha = 0.8) +
      ggplot2::scale_size_continuous(range = c(2, 8), guide = "none") +
      ggplot2::labs(x = x_axis, y = y_axis) +
      ggplot2::theme_minimal(base_size = 11) +
      ggplot2::theme(
        axis.title = ggplot2::element_text(size = 12, face = "bold"),
        axis.text = ggplot2::element_text(size = 10),
        plot.title = ggplot2::element_text(size = 14, hjust = 0.5),
        axis.title.x = ggplot2::element_text(margin = ggplot2::margin(t = 10)),
        axis.title.y = ggplot2::element_text(margin = ggplot2::margin(r = 10)),
        plot.margin = ggplot2::margin(5, 10, 5, 10)
      )

  } else {
    res.rcs <- NULL
    plot_nonlinear <- NULL
  }

  returnedlist <- list(
    linear_model = res.lin,
    linear_plot = plot_linear,
    nonlinear_model = res.rcs,
    nonlinear_plot = plot_nonlinear)
  class(returnedlist) <- "dose"
  return(returnedlist)
}
