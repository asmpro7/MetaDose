# MetaDose Shiny App - UI Layout
# Elegant dashboard layout for linear & nonlinear dose-response meta-regression
# Package: MetaDose

library(shiny)
library(bslib)
library(DT)

ui <- navbarPage(
  title = "MetaDose",
  theme = bs_theme(
    version = 5,
    bootswatch = "flatly",
    primary = "#2C3E50",
    base_font = font_google("Inter")
  ),
  header = tags$head(
    tags$link(rel = "icon", type = "image/x-icon", href = "favicon.ico")
  ),

  # ============================
  # Tab 1: Data & Settings
  # ============================
  tabPanel(
    "Data & Settings",
    layout_sidebar(
      sidebar = sidebar(
        width = 320,
        h5("Model Settings"),
        selectInput(
          "outcome_type",
          "Type of outcome",
          choices = c("Continuous", "Binary")
        ),
        uiOutput("measure_ui"),
        checkboxGroupInput(
          "model_type",
          "Type of model",
          choices = c("Linear" = "linear", "Nonlinear" = "nonlinear"),
          selected = c("linear", "nonlinear")
        ),
        textInput("x_axis", "X-axis title", value = "Dose"),
        textInput("y_axis", "Y-axis title", value = "Measured Effect"),
        textInput(
          "knots",
          "Knots for nonlinear model (quantiles)",
          value = "0.10, 0.50, 0.90"
        )
        ,
        helpText("Comma-separated")
      ),

      card(
        full_screen = TRUE,
        card_header("Data Input"),
        layout_column_wrap(
          width = 1,
          downloadButton("download_template", "Download CSV Template"),
          fileInput("upload_data", "Upload CSV File", accept = ".csv")
        ),
        hr(),
        DTOutput("data_table")
      )
    )
  ),

  # ============================
  # Tab 2: Linear Results
  # ============================
  tabPanel(
    "Linear Results",
    layout_column_wrap(
      width = 1,
      card(
        card_header("Linear Dose-Response Meta-Regression"),
        verbatimTextOutput("linear_text"),
        plotOutput("linear_plot", height = "500px"),
        downloadButton("download_linear_plot", "Download Figure")
      )
    )
  ),

  # ============================
  # Tab 3: Nonlinear Results
  # ============================
  tabPanel(
    "Nonlinear Results",
    layout_column_wrap(
      width = 1,
      card(
        card_header("Nonlinear Dose-Response Meta-Regression"),
        verbatimTextOutput("nonlinear_text"),
        plotOutput("nonlinear_plot", height = "500px"),
        downloadButton("download_nonlinear_plot", "Download Figure")
      )
    )
  ),

  # ============================
  # Tab 4: About & Citation
  # ============================
  tabPanel(
    "About & Citation",
    layout_column_wrap(
      width = 1/2,


      card(
        card_header("About MetaDose"),
        p(strong("Title:"), " Dose-Response Meta-Regression for Meta-Analysis"),
        p(strong("Version:"), " 1.0.1"),
        p(strong("Author:"),
          HTML('Ahmed Abdelmageed')
        ),
        p(strong("ORCID:"),
          HTML('<a href="https://orcid.org/0009-0002-7902-690X" target="_blank">0009-0002-7902-690X</a>')
        ),
        p(strong("Email:"), "ahmedelsaeedmassad@gmail.com"),
        p(strong("CRAN:"),
          HTML('<a href="https://cran.r-project.org/package=MetaDose" target="_blank">https://cran.r-project.org/package=MetaDose</a>')
        ),
        p(strong("GitHub:"),
          HTML('<a href="https://github.com/asmpro7/MetaDose/" target="_blank">https://github.com/asmpro7/MetaDose/</a>')
        ),
        p(strong("License:"), " GPL (>= 3)"),
        hr(),
        p(
          "MetaDose provides tools for conducting linear and nonlinear dose-response meta-regression using study-level summary data. ",
          "It supports both continuous and binary outcomes and allows modeling of dose-effect relationships ",
          "using linear trends or nonlinear restricted cubic splines, with built-in visualization."
        )
      ),


      card(
        card_header("Citation"),
        verbatimTextOutput("citation_text"),
        p("DOI: ", em("10.32614/CRAN.package.MetaDose"))
      )
    )
  )
)


# ============================
# Server Logic
# ============================

server <- function(input, output, session) {

  # ----------------------------
  # Dynamic measure selector
  # ----------------------------
  output$measure_ui <- renderUI({
    if (input$outcome_type == "Continuous") {
      selectInput(
        "measure",
        "Measure type",
        choices = c("Mean Difference" = "MD",
                    "Standardized Mean Difference" = "SMD")
      )
    } else {
      selectInput(
        "measure",
        "Measure type",
        choices = c("Risk Ratio" = "RR",
                    "Odds Ratio" = "OR")
      )
    }
  })

  # ----------------------------
  # CSV template generator
  # ----------------------------
  output$download_template <- downloadHandler(
    filename = function() {
      if (input$outcome_type == "Continuous") {
        "MetaDose_continuous_template.csv"
      } else {
        "MetaDose_binary_template.csv"
      }
    },
    content = function(file) {
      if (input$outcome_type == "Continuous") {
        template <- data.frame(
          id = NA,
          mean.e = NA,
          sd.e = NA,
          n.e = NA,
          mean.c = NA,
          sd.c = NA,
          n.c = NA,
          dose = NA
        )
      } else {
        template <- data.frame(
          id = NA,
          event.e = NA,
          n.e = NA,
          event.c = NA,
          n.c = NA,
          dose = NA
        )
      }
      write.csv(template, file, row.names = FALSE)
    }
  )

  # ----------------------------
  # Read uploaded data
  # ----------------------------
  data_reactive <- reactive({
    req(input$upload_data)
    read.csv(input$upload_data$datapath, stringsAsFactors = FALSE)
  })

  output$data_table <- renderDT({
    req(data_reactive())
    datatable(
      data_reactive(),
      options = list(pageLength = 10, scrollX = TRUE),
      editable = TRUE
    )
  })

  # ----------------------------
  # Run MetaDose models
  # ----------------------------
  model_fit <- reactive({
    req(data_reactive(), input$measure)

    dat <- data_reactive()

    linear_flag    <- "linear" %in% input$model_type
    nonlinear_flag <- "nonlinear" %in% input$model_type

    # parse knots
    knots_vec <- as.numeric(
      trimws(
        unlist(strsplit(input$knots, ","))
      )
    )

    knots_vec <- knots_vec[!is.na(knots_vec)]

    if (length(knots_vec) < 3) {
      knots_vec <- c(0.10, 0.50, 0.90)
    }


    if (input$outcome_type == "Continuous") {

      MetaDose::mdcont(
        measure = input$measure,
        mean.e  = mean.e,
        sd.e    = sd.e,
        n.e     = n.e,
        mean.c  = mean.c,
        sd.c    = sd.c,
        n.c     = n.c,
        dose    = dose,
        data    = dat,
        linear  = linear_flag,
        nonlinear = nonlinear_flag,
        x_axis  = input$x_axis,
        y_axis  = input$y_axis,
        knots   = knots_vec
      )


    } else {

      MetaDose::mdbin(
        measure = input$measure,
        event.e = event.e,
        n.e     = n.e,
        event.c = event.c,
        n.c     = n.c,
        dose    = dose,
        data    = dat,
        linear  = linear_flag,
        nonlinear = nonlinear_flag,
        x_axis  = input$x_axis,
        y_axis  = input$y_axis,
        knots   = knots_vec
      )

    }
  })

  # ----------------------------
  # Linear outputs (S3 methods)
  # ----------------------------
  output$linear_text <- renderPrint({
    req(model_fit())
    print(model_fit(), model = "linear")
  })

  output$linear_plot <- renderPlot({
    req(model_fit())
    model_fit()$linear_plot
  })

  output$download_linear_plot <- downloadHandler(
    filename = function() "linear_dose_response.png",
    content = function(file) {
      png(file, width = 2000, height = 1600, res = 300)
      print(model_fit()$linear_plot)
      dev.off()
    }
  )

  # ----------------------------
  # Nonlinear outputs (S3 methods)
  # ----------------------------
  output$nonlinear_text <- renderPrint({
    req(model_fit())
    print(model_fit(), model = "nonlinear")
  })

  output$nonlinear_plot <- renderPlot({
    req(model_fit())
    model_fit()$nonlinear_plot
  })

  output$download_nonlinear_plot <- downloadHandler(
    filename = function() "nonlinear_dose_response.png",
    content = function(file) {
      png(file, width = 2000, height = 1600, res = 300)
      print(model_fit()$nonlinear_plot)
      dev.off()
    }
  )

  # ----------------------------
  # Citation text
  # ----------------------------
  output$citation_text <- renderText({
    paste0(
      "Ahmed Abdelmageed (2026). MetaDose: Dose-Response Meta-Regression for Meta-Analysis.",
      " R package version 1.0.1, https://CRAN.R-project.org/package=MetaDose."
    )
  })
}
# ============================
# Run App
# ============================

shinyApp(ui = ui, server = server)

