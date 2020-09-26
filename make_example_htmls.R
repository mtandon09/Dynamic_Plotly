rm(list=ls())

library(datasets)

dataset_names <- unlist(lapply(strsplit(data()$results[,"Item"]," "),"[[",1))
dims <- sapply(dataset_names, function(currname){
  # currname=dataset_names[2]
  mydims=dim(eval(parse(text=currname)))
  if (is.null(mydims) | length(mydims) != 2) {  ## This excludes time series and ones with more than 2 dimensions
    return(NULL)
  } else {
    return(mydims)
  }

})

dims <- dims[unlist(lapply(dims, is.numeric))]
dims <- dims[unlist(lapply(dims, "[[",2)) > 4]  ## We want at least 4 columns to test 3D plotting + color

## Order
dims <- dims[order(unlist(lapply(dims, "[[",1)),decreasing = T)]

# dataset_details <- data()$results
# my_details <- dataset_details[dataset_details[,"Item"]==DATASETNAME,c("Item","Title")]
# dataset_details[dataset_details[,"Item"] %in% names(dims),c("Item","Title")]
# num_datasets <- 3
# selected_datasets <- names(dims)[c(1,which(as.logical(diff(cut(1:length(dims), num_datasets-1, labels = F)))),length(dims))]

# selected_datasets <- c("iris","swiss","Seatbelts")
selected_datasets <- c("baseball")


template <- readLines("dataset_page_template.txt")
mysupersecrettemplatevariable="helloiamavariablename"
currdataset=selected_datasets[1]

rmd_txt <- lapply(selected_datasets, function(currdataset) {
  gsub(mysupersecrettemplatevariable, currdataset, template)
})

base_template <- readLines("customizable_plotly.template.txt")

rmd_txt_to_write <- c(
  base_template,
  unlist(rmd_txt)
)


rmd_filename="large_dataset.Rmd"
writeLines(rmd_txt_to_write, rmd_filename)
rmarkdown::render(rmd_filename,output_format="all", output_file=gsub(".Rmd","",rmd_filename))



selected_datasets <- c("quakes","mtcars","Seatbelts","airquality")


template <- readLines("dataset_page_template.txt")
mysupersecrettemplatevariable="helloiamavariablename"
currdataset=selected_datasets[1]

rmd_txt <- lapply(selected_datasets, function(currdataset) {
  gsub(mysupersecrettemplatevariable, currdataset, template)
})

base_template <- readLines("customizable_plotly.template.txt")

rmd_txt_to_write <- c(
  base_template,
  unlist(rmd_txt)
)


rmd_filename="small_dataset.Rmd"
writeLines(rmd_txt_to_write, rmd_filename)
rmarkdown::render(rmd_filename,output_format="all", output_file=gsub(".Rmd","",rmd_filename))





# DATASETNAME="Seatbelts"
# dataset_details <- data()$results
# my_details <- dataset_details[dataset_details[,"Item"]==DATASETNAME,c("Item","Title")]
# names(my_details) <- c("Dataset","Description")
# print(my_details)
# 
