#Increase size of upload files to 500 Mo
options(shiny.maxRequestSize=500*1024^2)
options(warn=-1)

if (!require("shiny"))
    install.packages("shiny")  

if (!require("shinythemes"))
    install.packages('shinythemes')

if (!require("shinydashboard"))
    install.packages("shinydashboard")

if (!require("dplyr"))
    install.packages("dplyr")

if (!requireNamespace("BiocManager", quietly = TRUE))
install.packages("BiocManager")

if (!require("biomaRt"))
BiocManager::install("biomaRt")

#source("https://bioconductor.org/biocLite.R")
library(shiny)
library(shinythemes)
library(shinydashboard)
library(dplyr)
library(biomaRt)

ui <- tagList(
  dashboardPage(
    dashboardHeader(
      title = "Obtain Attributes for Genes",
      titleWidth = 380
    ),
    dashboardSidebar(
      radioButtons("species", label=h3("Select a species"),
                   choices=list("Mouse" = 1,
                                "Human" = 2),
                   selected = 1),
      width = 380,
      h3("Output print options"),
      checkboxInput("output_ENSMUS", "Add ENSEMBL geneID column.", value = TRUE),
      checkboxInput("output_GENENAME", "Add gene name column.", value = TRUE),
      checkboxInput("output_BIOTYPE", "Add gene biotype column.", value = FALSE),
      checkboxInput("output_CHR", "Add gene chomosome column.", value = FALSE),
      checkboxInput("output_BEG", "Add gene start location column.", value = FALSE),
      checkboxInput("output_END", "Add gene end location column.", value = FALSE),
      checkboxInput("output_DESC", "Add gene description column.", value = FALSE),
      radioButtons("type", label=h3("Select a input type"), choices=list("Ensembl Gene IDs" = 1, "Gene names" = 2),  selected = 1),
      br(),
      numericInput("colnb", h3("Column number containing the Ensembl Gene IDs or Gene names"), 1, min = 1, max = 100, step = 1, width = NULL),
      br(),
      fileInput("file2", h3("Upload a list of Ensembl Gene IDs or Gene names"), multiple = TRUE,
                accept = c("text/csv", "text/comma-separated-values, text/plain", ".csv")),

#      h3("Sample datasets"),
#      downloadButton("example1", "Dataset 1", icon("paper-plane"),
#                     style="color: #fff; background-color: maroon; 
#                     border-color: black"),
      #      br(),
#      br(),
#      downloadButton("example2", "Dataset 2", icon("paper-plane"), style="color: #fff; background-color: maroon; border-color: black"),
      # hr(),
      br(),
      h3("Export data to a text file"),
      downloadButton("downloadData", "Download", icon("paper-plane"),
                     style="color: #fff; background-color: maroon; 
                     border-color: black")
      
      
      ),
    body <- dashboardBody(
      tags$head(
        tags$link(rel="stylesheet", type = "text/css", href = "custom.css"),
        tags$head(includeScript("google-analytics.js"))
      ),#background = "light-blue",height = 330, width = 100, 
#      box(collapsible=T,
#          tags$h3("About"),
#          tags$p("This application obtains the coordinates and description of genes in 
#                 a gene list."),
#          tags$h3("Instructions"),
#          tags$ol(
#            tags$li("Select a species"),
#            tags$li("Choose your options"),
#            tags$li("Upload a file genelist/sample dataset"),
#            tags$li("Wait ..."),
#            tags$li("Done!"),
#            tags$li("If you wish, you may export the table by clicking on the 'Download' button")
#          ),
#          tags$h3("Contact"), 
#          tags$p("Manuel LEBEURRIER","[manuel.lebeurrier@inserm.fr]", br(), tags$a(href="https://www.cptp.inserm.fr/en/technical-platforms/genomic-and-transcriptomic/", "Genomic and transcriptomic platform CPTP", target="_blank"))
#          ),
      fluidPage(
        column(width = 10, box(collapsible=T, title = "Results", width = NULL, status = "primary", div(style = 'overflow-x: scroll', tableOutput("output_geneids"))))
        #tableOutput("output_geneids"))
      )
    ),
    skin="red")
)
