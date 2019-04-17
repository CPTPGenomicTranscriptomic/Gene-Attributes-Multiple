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

server <- function(input, output) {
  #Increase size of upload files to 500 Mo
  options(shiny.maxRequestSize=500*1024^2)
  output$inputFiles <- renderText({
    req(input$file2)
    print(input$file2$name)
  })
  
  datasetInput <- reactive({
    req(input$file2)
    file2 <- input$file2
    output_GENENAME=input$output_GENENAME
    output_BIOTYPE=input$output_BIOTYPE
    output_CHR=input$output_CHR
    output_BEG=input$output_BEG
    output_END=input$output_END
    output_DESC=input$output_DESC
    if (is.null(file2)) {
      return(NULL)
    }# else{
    # #go to a temp dir to avoid permission issues
    #  owd <- setwd(tempdir())
    #  on.exit(setwd(owd))
    #  files <- NULL;
    #}
    
    withProgress(message = 'Running:', value = 0, {
      print(file2)
      for(i in 1:length(file2$name)) {
          incProgress(i/(length(file2$name)), detail = paste("Working on the file:", file2$name[i]))
          withProgress(message = 'In progress:', value = 0, {
          incProgress(1/4, detail = "Reading input file.")
          # read input genes
          data1 <- data.frame(read.table(file2$datapath[i], stringsAsFactors = F, header=T))
          #print(data1)
          
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
          #print(fileText)
          #print(file2$name[i])
          write.table(fileText,file2$name[i], row.names = F, quote = F, sep = "\t")
          #print("write")
          print(fileText)
          })
      }
      print(paste0("If this message appears the program have reach the end! You can look at \"",getwd(),"\" directory to see the results or download them!"))
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
  
  
#  output$downloadData <- downloadHandler(
#    filename = function() {input$file2$name},
#    content = function(file){
#      write.table(datasetInput(), file, row.names = F, quote = F, sep = "\t")
#    }
#  )
  output$downloadData <- downloadHandler(
    filename = function(){
      paste("output", "zip", sep=".")
    },
    content = function(file){
      files <- NULL;
        for(i in 1:length(input$file2$name)) {
          files <- c(input$file2$name[i],files)
        }
      #create the zip file
      zip(file,files = files)
    },
    contentType = "application/zip"
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
