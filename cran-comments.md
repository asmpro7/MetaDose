## CRAN Submission for MetaDose 1.0.0


Purpose:
The MetaDose package provides tools to perform linear and nonlinear dose-response meta-regression on study-level summary data. It supports both continuous outcomes (mdcont()) and binary outcomes (mdbin()). Users can model dose-effect relationships using linear trends or restricted cubic splines for flexible nonlinear modeling. The package also includes visualization of dose-response curves and convenient print() and plot() methods for inspecting results.

Key Functions:

* mdcont(): Linear and nonlinear dose-response meta-regression for continuous outcomes.

* mdbin(): Linear and nonlinear dose-response meta-regression for binary outcomes.

* print.dose(), plot.dose(): S3 methods for summarizing and plotting results returned from mdcont() and mdbin().

S3 Methods:

* Objects returned by mdcont() and mdbin() are of class "dose".

* print(x) displays the linear and/or nonlinear model summaries.

* plot(x) produces the corresponding dose-response plots using ggplot2.

Dependencies:

* metafor (for rma() and escalc())

* rms (for rcs())

* ggplot2 (for plotting)

All imported functions are explicitly imported using @importFrom to avoid namespace issues.
