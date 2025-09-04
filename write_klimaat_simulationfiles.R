library(dplyr)
library(xml2)

#load helper functions: assign seedlings and replacement of climate values
source("./assignseedlings.R", echo=TRUE)
source("./replace_climate_values.R", echo=TRUE)

#choose number of simulations
n <- 20



#set up helping dataframes


  # plotinfo can also directly be changed in the start parameterfile, but it is easier to do it here
  # x is the length in meters in east-west orientation, y is the length in north-south orientation
  # map2024 gives the directory to the treemap
plotinfo <- data.frame(
  id = c(36, 38, 44, 50, 51),
  x = c(56, 120, 61, 52, 63),
  y = c(101, 45, 82, 98, 30),
  map2024 = c(
    ".\\treemap_36_2024.txt",
    ".\\treemap_38_2024.txt",
    ".\\treemap_44_2024.txt",
    ".\\treemap_50_2024.txt",
    ".\\treemap_51_2024.txt"
  ),
  stringsAsFactors = FALSE
)

# this is the reproduction, can also be adjusted in start paramaterfile, but it is easier to change it here
lambdas <- data.frame(
  id  = c(36, 38, 44 ,50, 51),
  lambdaPRSE = c(0.322, 0.2324, 0.289, 0.00998, 0.015),
  lambdaSOAU = c(0.00670, 0.2376, 0.00656, 0.002155, 0.002155),
  lambdaILAQ = c(0.00216, 0.001, 0.00106, 0.00022, 0.00022),
  lambdaQURO = c(0.001, 0.001, 0.011, 0.001216, 0.001216),
  lambdaBEPE = c(0.001, 0.001, 0.21, 0.001, 0.001),
  lambdaSAMB = c(0.001, 0.001, 0.0521, 0.00417, 0.00417),
  lambdaTAXU = c(0.001, 0.001, 0.00076, 0.001, 0.001),
  lambdaCOAV = c(0.001, 0.001, 0.00015, 0.001, 0.001),
  lambdaFRAL = c(0.001, 0.001, 0.0127, 0.001, 0.001),
  lambdaCRMO = c(0.001, 0.001, 0.325, 0.001, 0.001),
  lambdaRIRU = c(0.001, 0.001, 0.00188, 0.001, 0.001),
  lambdaCABE = c(0.001, 0.001, 0.00167, 0.001, 0.001),
  lambdaPOAL = c(0.0, 0.0, 0.0, 0.0, 0.005)
)

for(map in plotinfo$id){

#load start_paramerfile
file <- sprintf("start_parameterfile_shade_%s.xml", map)

#add seedling mortality
doc <- add_seedling(file) 

doc_copy <- doc
row_info <- plotinfo[plotinfo$id == map, ]

#set plotinfo and treemap
xml_set_text(xml_find_first(doc_copy, ".//plot_lenX"), as.character(row_info$x))
xml_set_text(xml_find_first(doc_copy, ".//plot_lenY"), as.character(row_info$y))
xml_set_text(xml_find_first(doc_copy, ".//tr_treemapFile"), row_info[["map2024"]])

#set lambdas
lambda_row <- lambdas[lambdas$id == map, ]
lambda_pos <- doc_copy |> 
  xml_find_first(".//di_nonSpatialInterceptOfLambda") |>
  xml_find_all(".//di_nsiolVal")

for (node in lambda_pos) {
  species <- xml_attr(node, "species")
  column_name <- paste0("lambda", species)
  if (column_name %in% names(lambda_row)) {
    xml_text(node) <- as.character(lambda_row[[column_name]])  # your desired value
  }
}



#change climate values, in this case baseline scenario and climate change scenario
scenarios <- c("Ln", "Hd")
for(scenario in scenarios){
  #dir.create(sprintf("klimaat/output/%s", scenario))}
for (j in 1:n) {
  #adjust climate variables
  ens <- sample(1:8, 1) #get random weather data set
  doc_copy <- replace_climate_values(doc_copy, scenario, ens, WC = TRUE, start_year = 2025)
  
  
  #adjust output directory to liking
  ou_filename_node <- xml_find_first(doc_copy, ".//ou_filename")
  unique_filename <- sprintf("C:\\Users\\corne\\OneDrive - UGent\\thesis\\simulations\\klimaat\\output_shade\\%s\\%s_%03d.xml",scenario, map, j)
  
  
  xml_text(ou_filename_node) <- unique_filename
  
  #save parameterfile in desired directory
  filename <- sprintf("klimaat/sim_%s_%s_%03d.xml", map, scenario, j)
  
  write_xml(doc_copy, filename)
}
}

}
