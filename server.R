#Increase size of upload files to 500 Mo
options(shiny.maxRequestSize=500*1024^2)
options(warn=-1)

source("https://bioconductor.org/biocLite.R")
library(biomaRt)
library(shiny)
library(shinythemes)
library(dplyr)
library(shinydashboard)

server <- function(input, output) {
  datasetInput <- reactive({
    file2 <- input$file2
    output_GENENAME=input$output_GENENAME
    output_BIOTYPE=input$output_BIOTYPE
    output_CHR=input$output_CHR
    output_BEG=input$output_BEG
    output_END=input$output_END
    output_DESC=input$output_DESC
    if (is.null(file2)) {
      return(NULL)
    }
    
    withProgress(message = 'In progress:', value = 0, {
      incProgress(1/4, detail = paste("Reading input file:", file2$name))
      # read input genes
      data1 <- data.frame(read.table(file2$datapath, stringsAsFactors = F, header=T))

      # determine species
      if (input$species == 1) {
        dataset_name <- "mmusculus_gene_ensembl"
      } else if (input$species == 2) {
        dataset_name <- "hsapiens_gene_ensembl"
        data1 <- data.frame(lapply(data1, function(v) {
          if (is.character(v)) return(toupper(v))
          else return(v)
        }))
      }
      
      # determine type
      if(input$type == 1){
        common_col = "ensembl_gene_id"
        savedcolname = colnames(data1)[input$colnb]
        colnames(data1) = c("ensembl_gene_id",colnames(data1)[-1])
      } else {
        common_col = "external_gene_name"
        savedcolname = colnames(data1)[input$colnb]
        colnames(data1) = c("external_gene_name",colnames(data1)[-1])
      }
      
      #Ensembl mapping according options
      incProgress(2/4, detail = "Loading Ensembl data")
      ensembl <- useMart("ensembl", dataset = dataset_name)
      listofattributes = c('ensembl_gene_id')
      if(output_GENENAME){
        listofattributes = c(listofattributes,'external_gene_name')
      }
      if(output_BIOTYPE){
        listofattributes = c(listofattributes,'gene_biotype')
      }
      if(output_CHR){
        listofattributes = c(listofattributes,'chromosome_name')
      }
      if(output_BEG){
       listofattributes = c(listofattributes,'start_position')
      }
      if(output_END){
        listofattributes = c(listofattributes,'end_position')
      }
      if(output_DESC){
        listofattributes = c(listofattributes,'description')
      }
      incProgress(3/4, detail = "Request Ensembl database")
      mapping <- getBM(attributes = listofattributes, values = data1, mart = ensembl)
      incProgress(4/4, detail = "Merge results")
      fileText <-merge(mapping,data1)
      print(fileText)
      })
  })
  #mapping_example_data <- getBM(mart = useMart("ensembl", host="http://aug2017.archive.ensembl.org", dataset = "mmusculus_gene_ensembl"), attributes = c('external_gene_name', 'ensembl_gene_id'))
  #mapping_example_data <- sample_n(data.frame(mapping_example_data), 20)
  #example_data1 <- as.data.frame(mapping_example_data$external_gene_name)
  #example_data2 <- as.data.frame(mapping_example_data$ensembl_gene_id)
  
  output$output_geneids <- renderTable({
    options = list(scrollX = TRUE)
    datasetInput()
  })
  
  output$downloadData <- downloadHandler(
    filename = function() {input$file2$name},
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
