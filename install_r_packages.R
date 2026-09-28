# Create a list of start-up packages 
# DBI is a dependency of odbc
install_startup_packages <- c("yaml", "glue", "data.table", "odbc", "readr", "dplyr",  
                            "optparse", "viridis")   

# And finally we install the required packages including their dependencies
for(pkg in install_startup_packages) utils::install.packages(pkg, dependencies = T, repos='http://cran.rstudio.com/')


