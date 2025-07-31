library(xml2)

add_seedling <- function(file_path, output_path = NULL) {
  # Read the XML file
  xml_doc <- read_xml(file_path)
  
  # Find all behavior nodes
  behavior_nodes <- xml_find_all(xml_doc, ".//behavior")
  
  for (node in behavior_nodes) {
    behavior_name <- xml_text(xml_find_first(node, "./behaviorName"))
    
    # Only target the NCIMasterMortality behavior
    if (behavior_name == "NCIMasterMortality") {
      # Get all species already listed as Saplings
      sapling_nodes <- xml_find_all(node, './applyTo[@type="Sapling"]')
      sapling_species <- xml_attr(sapling_nodes, "species")
      
      # Get species already listed as Seedlings to avoid duplicates
      seedling_species <- xml_attr(xml_find_all(node, './applyTo[@type="Seedling"]'), "species")
      
      # Determine which species need new Seedling applyTo tags
      species_to_add <- setdiff(sapling_species, seedling_species)
      
      for (species in species_to_add) {
        # Create new applyTo node as a string and read it into an XML node
        new_node <- read_xml(sprintf('<applyTo species="%s" type="Seedling"/>', species))
        xml_add_child(node, new_node)
      }
    }
  }
  
  
  # Ensure each species in RemoveDead behavior has a Seedling entry
  remove_dead_nodes <- xml_find_all(xml_doc, ".//behavior[behaviorName='RemoveDead']")
  
  for (node in remove_dead_nodes) {
    # Get all species in the block (for any type)
    all_applyto <- xml_find_all(node, "./applyTo")
    all_species <- unique(xml_attr(all_applyto, "species"))
    
    # Get species that already have a Seedling entry
    seedling_applyto <- xml_find_all(node, "./applyTo[@type='Seedling']")
    seedling_species <- xml_attr(seedling_applyto, "species")
    
    # Determine which species need Seedling entries
    missing_species <- setdiff(all_species, seedling_species)
    
    # Add missing Seedling entries
    for (species in missing_species) {
      new_node <- read_xml(sprintf('<applyTo species="%s" type="Seedling"/>', species))
      xml_add_child(node, new_node)
    }
  }
  

  
  
  # Add a prefix to the ou_filename path
  prefix <- "SA_"  # Change this to whatever you want
  
  ou_node <- xml_find_first(xml_doc, ".//ou_filename")
  if (!is.na(ou_node)) {
    original_text <- xml_text(ou_node)
    new_text <- file.path(dirname(original_text), paste0(prefix, basename(original_text)))
    xml_text(ou_node) <- new_text
  }
  
  # Save or return modified XML
  if (!is.null(output_path)) {
    write_xml(xml_doc, output_path)
  }
  
  return(xml_doc)
}
