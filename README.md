# Thesis_2025
Extra files for my thesis 'A spatially explicit forest growth model for managing Prunus serotina: a case study of the Clingse Bossen, The Netherlands'. The species-specific parameters can be found by downloading one of the XML parameter files. To recreate the results (base and climate change scenario), the following steps must be done.

1. The SORTIE-ND code must be modified with NCIMasterMortality.cpp to allow for seedlings to be included in the juvenile mortality behavior. Instructions for setting up the SORTIE-ND code can be found on   http://sortie-nd.org/help/manuals/developer_documentation/software/code_installation.html. When building the code, replace the original 'NCIMasterMortality.cpp' with the updated one.
2. The R-file 'write_klimaat_simulationfiles.R' creates 20 parameter files for each map. The output directory on line 95 needs to be updated by you; this is where SORTIE-ND will save the output.
3. The created parameter files can be turned into a batch file in the SORTIE-ND GUI.
4. Run the batch file from the updated SORTIE.exe.  
