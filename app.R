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
    skin="red"),
  tags$footer("Manuel LEBEURRIER",br(),align = "right", 
              style = "
              position: relative;
              margin-top: -50px;
              bottom: 0px;
              width: 100%;
              height:50px;
              clear: both;
              color: white;
              padding: 10px;
              background-color: orangered;
              z-index: 1000;
              left: 0", 
              a(href="https://www.cptp.inserm.fr/en/technical-platforms/genomic-and-transcriptomic/", 
                "Genomic and transcriptomic platform CPTP", 
                target="_blank", style="color: lightblue"
              )
  )
    )

server <- function(input, output) {
  datasetInput <- reactive({
    file2 <- input$file2
    if (is.null(file2)) {
      return(NULL)
    }
    
    # read input genes
    data1 <- data.frame(read.table(file2$datapath, stringsAsFactors = F))
    
    
    # determine species
    if (input$radio == 1) {
      dataset_name <- "mmusculus_gene_ensembl"
    } else if (input$radio == 2) {
      dataset_name <- "hsapiens_gene_ensembl"
      data1 <- data.frame(lapply(data1, function(v) {
        if (is.character(v)) return(toupper(v))
        else return(v)
      }))
    }
    
    if(length(data1[grepl("^ENS", data1$V1),]) > length(data1[!grepl("^ENS", data1$V1),])){
      common_col = "ensembl_gene_id"
    } else {
      common_col = "external_gene_name"
    }
    
    colnames(data1) <- c(common_col) 
    
    ensembl <- useMart("ensembl", dataset = dataset_name)
    
    listofattributes = c('ensembl_gene_id')
    if(output_GENENAME)
      listofattributes = c(listofattributes,'external_gene_name')
    if(output_BIOTYPE)
      listofattributes = c(listofattributes,'gene_biotype')
    if(output_CHR)
      listofattributes = c(listofattributes,'chromosome_name')
    if(output_BEG)
      listofattributes = c(listofattributes,'start_position')
    if(output_END)
      listofattributes = c(listofattributes,'end_position')
    if(output_DESC)
      listofattributes = c(listofattributes,'description')
    
    mapping <- getBM(attributes = listofattributes, values = data1, mart = ensembl)
    
        
    fileText <- left_join(y=data1, x=mapping,  by=common_col)
    
  })
  mapping_example_data <- getBM(mart = useMart("ensembl", host="http://aug2017.archive.ensembl.org", dataset = "mmusculus_gene_ensembl"), attributes = c('external_gene_name', 'ensembl_gene_id'))
  mapping_example_data <- sample_n(data.frame(mapping_example_data), 20)
  example_data1 <- as.data.frame(mapping_example_data$external_gene_name)
  example_data2 <- as.data.frame(mapping_example_data$ensembl_gene_id)
  
  
  output$output_geneids <- renderTable({
    datasetInput()
  })
  
  
  output$downloadData <- downloadHandler(
    filename = function() {"output.txt"},
    content = function(file){
      write.table(datasetInput(), file, row.names = F, quote = F, sep = "\t")
    }
  )
  
  output$example1 <- downloadHandler(
    filename = function() {"example1.txt"},
    content = function(file){
      write.table(example_data1, file, row.names = F, quote = F, sep = "\t", col.names = F)
    }
  )
  output$example2 <- downloadHandler(
    filename = function() {"example2.txt"},
    content = function(file){
      write.table(example_data2, file, row.names = F, quote = F, sep = "\t", col.names = F)
    }
  )
}

shinyApp(ui = ui, server = server)
