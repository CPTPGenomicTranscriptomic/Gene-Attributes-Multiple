Gene-Attributes-Multiple
========
A shiny app that obtains Ensembl gene ID, gene names, the coordinates and description of multiple input files using biomaRt package. 

*****

Launch Gene-Attributes-Multiple directly from R and GitHub (preferred approach)

User can choose to run Gene-Attributes-Multiple installed locally for a more preferable experience.

## Step 1: Install R and RStudio

Before running the app you will need to have R and RStudio installed (tested with R 3.5.3 and RStudio 1.1.463).  
Please check CRAN (<a href="https://cran.r-project.org/" target="_blank">https://cran.r-project.org/</a>) for the installation of R.  
Please check <a href="https://www.rstudio.com/" target="_blank">https://www.rstudio.com/</a> for the installation of RStudio. 
Please check <a href="https://cran.r-project.org/bin/windows/Rtools/" target="_blank">https://cran.r-project.org/bin/windows/Rtools</a> for the installation of Rtools.

## Step 2: Install the R Shiny package

Start an R session using RStudio and run this line:  
```
if (!require("shiny")){install.packages("shiny")}
```

## Step 3: Start the app  

Start an R session using RStudio and run this line:  
```
shiny::runGitHub("Gene-Attributes-Multiple", "CPTPGenomicTranscriptomic")
```
This command will download the code of Gene-Attributes-Multiple from GitHub to a temporary directory of your computer and then launch the Gene-Attributes-Multiple app in the web browser. Once the web browser was closed, the downloaded code of Gene-Attributes-Multiple would be deleted from your computer. Next time when you run this command in RStudio, it will download the source code of Gene-Attributes-Multiple from GitHub to a temporary directory again. 

## Step 4: Choose your analysis set up  

**1. Choose the species:**

Select the species you are working on: Mouse or Human.

ENSG... refers to Human genes.

ENSMUSG... refers to Mouse genes.

**2. Choose output print options:**

- Add ENSEMBL geneID column.
- Add gene name column.
- Add gene biotype column.
- Add gene chomosome column.
- Add gene start location column.
- Add gene end location column.
- Add gene description column.

**3. Select input type:**

- Ensembl Gene IDs
- Gene names 

**4. Column number containing the Ensembl Gene IDs or Gene names:**

Select the column number corresponding to the Ensembl Gene IDs or Gene names you want to annotate (1 if it's the first column).

**5. Upload a list of Ensembl Gene IDs or Gene names:**

Upload from one to serveral files having a header (colnames as first row) and containing the Ensembl Gene IDs or Gene names you want to annotate.

The files must have the format text/csv, text/comma-separated-values, text/plain, or .csv extension to appear in the selection browser.

Be aware that the application is limited to 500Mo of RAM.

Multiple runs can be preferable in case of big data analyses.

The blue progress bar should move until the message \"upload complete\" appears.


**6. Export data to a text file:**

The button will create a zip file corresponding to all the input files annotated.

The webpage should look like this!

![alt text](https://github.com/CPTPGenomicTranscriptomic/Gene-Attributes-Multiple/blob/master/Gene-Attributes-Multiple_interface.png)
