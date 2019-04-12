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
    if(input$output_GENENAME)
      listofattributes = c(listofattributes,'external_gene_name')
    if(input$output_BIOTYPE)
      listofattributes = c(listofattributes,'gene_biotype')
    if(input$output_CHR)
      listofattributes = c(listofattributes,'chromosome_name')
    if(input$output_BEG)
      listofattributes = c(listofattributes,'start_position')
    if(input$output_END)
      listofattributes = c(listofattributes,'end_position')
    if(input$output_DESC)
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
