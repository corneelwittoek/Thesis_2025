replace_climate_values <- function(xml, scenario, i, WC = FALSE, start_year = 2019) {
  #load correct precipitation data depending on WC TRUE/FALSE
  #precipitation and temperature data are available on www.knmi.nl/nederland-nu/klimatologie/monv/reeksen and www.knmi.nl/nederland-nu/klimatologie/daggegevens
  if(WC){
    df_precip <- read.table(paste0("neerslag_WC/pr_", scenario, "_0", i, ".txt"), header = TRUE, sep = "\t") %>%
      filter(year >= start_year)
  }else{
  df_precip <- read.table(paste0("neerslag/pr_", scenario, "_0", i, ".txt"), header = TRUE, sep = "\t")%>%
    filter(year >= start_year)
  }
  df_temp <- read.table(paste0("temperatuur/tas_", scenario, "_0", i, ".txt"), header = TRUE, sep = "\t")%>%
    filter(year >= start_year)
  
  month_nodes <- c(
    January = "Jan", February = "Feb", March = "Mar", April = "Apr", May = "May", June = "Jun",
    July = "Jul", August = "Aug", September = "Sep", October = "Oct", November = "Nov", December = "Dec"
  )
  
  # Tag name fragments specific to XML structure
  node_suffixes <- list(
    sc_ciMonthlyTemp = c(
      Jan = "sc_cimtjanVal", Feb = "sc_cimtfebVal", Mar = "sc_cimtmarVal", Apr = "sc_cimtaprVal",
      May = "sc_cimtmayVal", Jun = "sc_cimtjunVal", Jul = "sc_cimtjulVal", Aug = "sc_cimtaugVal",
      Sep = "sc_cimtsepVal", Oct = "sc_cimtoctVal", Nov = "sc_cimtnovVal", Dec = "sc_cimtdecVal"
    ),
    sc_ciMonthlyPpt = c(
      Jan = "sc_cimpjanVal", Feb = "sc_cimpfebVal", Mar = "sc_cimpmarVal", Apr = "sc_cimpaprVal",
      May = "sc_cimpmayVal", Jun = "sc_cimpjunVal", Jul = "sc_cimpjulVal", Aug = "sc_cimpaugVal",
      Sep = "sc_cimpsepVal", Oct = "sc_cimpoctVal", Nov = "sc_cimpnovVal", Dec = "sc_cimpdecVal"
    )
  )
  var_types <- c("sc_ciMonthlyTemp", "sc_ciMonthlyPpt")
  for(var_type in var_types){
  for (month in names(month_nodes)) {
    parent_tag <- paste0(var_type, month_nodes[[month]])
    value_tag <- node_suffixes[[var_type]][[month_nodes[[month]]]]
    
    parent_node <- xml_find_first(xml, paste0(".//", parent_tag))
    if (is.na(parent_node)) {
      warning("Parent node not found: ", parent_tag)
      next
    }
    
    nodes <- xml_find_all(parent_node, paste0(".//", value_tag))
    
    if(var_type == "sc_ciMonthlyTemp"){values <- select(df_temp, month)}else {values <- select(df_precip, month)
    }
    
    
    if (nrow(values) != length(nodes)) {
      warning(sprintf("Mismatch in count for %s: %d values, %d XML nodes", month, length(values), length(nodes)))
    }
    
    for (j in seq_along(nodes)) {
      xml_text(nodes[j]) <- sprintf("%.2f", values[j,1])
    }
  }
  }
  return(xml)
}
