<p align="center">
  <h1 align="center"> MetaDose </h1>
<p align="center"> <img src="https://github.com/user-attachments/assets/89b1338a-2638-44ac-afb1-065fe3c92f41" data-canonical-src="https://github.com/user-attachments/assets/89b1338a-2638-44ac-afb1-065fe3c92f41" width="300" height="300" />
<p align="center">

<p>
<h2 align="center" id="MetaDesc">Linear and Nonlinear Dose-Response Meta-Regression</h2>
</p>

## Overview

`MetaDose` provides a suite of functions to perform linear and nonlinear dose-response meta-regression on study-level data. It supports both continuous (`mdcont()`) and binary (`mdbin()`) outcomes, with visualization and S3 methods for easy inspection of results.  

The workflow is:

1. **Model:** Use `mdcont()` for continuous outcomes or `mdbin()` for binary outcomes to estimate linear or nonlinear dose-response relationships, including restricted cubic spline modeling.
2. **Visualize:** Use the returned `dose` object’s `plot()` method to generate publication-ready dose-response plots, and `print()` to inspect the model summaries.
3. **Interact:** For users who prefer a graphical interface, `MetaDose` provides an interactive Shiny application. The app allows uploading data, performing linear or nonlinear dose-response meta-regression, and visualizing results without writing R code.

The Shiny app is hosted online and can be accessed here: [MetaDose Shiny App](https://asmpro.shinyapps.io/MetaDose/)

This approach helps researchers understand the relationship between dose and outcome in a meta-analytic context, providing both numerical and graphical summaries.

---

## Installation

Install the development version of `MetaDose` from GitHub with:

```r
# install.packages("remotes")
remotes::install_github("asmpro7/MetaDose")
```

---

## Example Usage

Continuous Outcome Example

```r
# Perform linear and nonlinear dose-response meta-regression
cont_results <- mdcont(
  data = study_data,
  mean.e = mean_e,
  sd.e = sd_e,
  n.e = n_e,
  mean.c = mean_c,
  sd.c = sd_c,
  n.c = n_c,
  dose = dose,
  measure = "MD"
)

# Print both linear and nonlinear model summaries
print(cont_results, model = "both")

# Plot the dose-response curves
plot(cont_results, model = "both")
```
Binary Outcome Example

```r
# Perform linear and nonlinear dose-response meta-regression
bin_results <- mdbin(
  data = study_data,
  event.e = event_e,
  n.e = n_e,
  event.c = event_c,
  n.c = n_c,
  dose = dose,
  measure = "RR"
)

# Print model summaries
print(bin_results, model = "both")

# Plot the dose-response curves
plot(bin_results, model = "both")
```
---
