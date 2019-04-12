#Increase size of upload files to 500 Mo
options(shiny.maxRequestSize=500*1024^2)
options(warn=-1)

source("https://bioconductor.org/biocLite.R")
library(biomaRt)
library(shiny)
library(shinythemes)
library(dplyr)
library(shinydashboard)

ui <- tagList(
  dashboardPage(
    dashboardHeader(
      title = "Obtain Attributes for Genes",
      titleWidth = 380
    ),
    dashboardSidebar(
      titlewidth = 380,
      radioButtons("radio", label=h3("Select a species"),
                   choices=list("Mouse" = 1,
                                "Human" = 2),
                   selected = 1),
      width = 380,
      checkboxInput("output_ENSMUS", "Print the column containg the ENSEMBL geneID .", value = FALSE),
      checkboxInput("output_GENENAME", "Print the column containg the gene name.", value = TRUE),
      checkboxInput("output_BIOTYPE", "Print the column containg the gene biotype.", value = FALSE),
      checkboxInput("output_CHR", "Print the column containg the gene chomosome.", value = FALSE),
      checkboxInput("output_BEG", "Print the column containg the gene start location.", value = FALSE),
      checkboxInput("output_END", "Print the column containg the gene end location.", value = FALSE),
      checkboxInput("output_DESCR", "Print the column containg the gene description.", value = FALSE),
      
      fileInput("file2", h3("Upload a list of Ensembl Gene IDs or Gene names"), 
                accept = c("text/csv", "text/comma-separated-values, 
                           text/plain", ".csv")),
      h3("Sample datasets"),
      downloadButton("example1", "Dataset 1", icon("paper-plane"),
                     style="color: #fff; background-color: maroon; 
                     border-color: black"),
      br(),
      br(),
      downloadButton("example2", "Dataset 2", icon("paper-plane"),
                     style="color: #fff; background-color: maroon; 
                     border-color: black"),
      
      # hr(),
      br(),
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
      box(collapsible=T,
          tags$h3("About"),
          tags$p("This application obtains the coordinates and description of genes in 
                 a gene list."),
          tags$h3("Instructions"),
          tags$ol(
            tags$li("Select a species"),
            tags$li("Upload a genelist/sample dataset"),
            tags$li("Wait ..."),
            tags$li("Done!"),
            tags$li("If you wish, you may export the table by clicking on the 'Download' button")
          ),
          tags$h3("Contact"), 
          tags$p("Manuel LEBEURRIER","[manuel.lebeurrier@inserm.fr]", br(), tags$a(href="https://www.cptp.inserm.fr/en/technical-platforms/genomic-and-transcriptomic/", "Genomic and transcriptomic platform CPTP", target="_blank"))
          ),
      
      
      fluidPage(
        tableOutput("output_geneids")
      )
    ),
    skin="red")
#  tags$footer("Manuel LEBEURRIER",br(),align = "right", 
#              style = "
#              position: relative;
#              margin-top: -50px;
#              bottom: 0px;
#              width: 100%;
#              height:50px;
#              clear: both;
#              color: white;
#              padding: 10px;
#              background-color: orangered;
#              z-index: 1000;
#              left: 0", 
#              a(href="https://www.cptp.inserm.fr/en/technical-platforms/genomic-and-transcriptomic/", 
#                "Genomic and transcriptomic platform CPTP", 
#                target="_blank", style="color: lightblue"
#              )
#  )
)
