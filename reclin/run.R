source("00_importSivep.R")
source("01_makeDataset.R")
source("02_recLinkage.R")

files <- dir(pattern = ".R$|.md|.gz")
dest_folder <- "../../beluzo-malaria/reclin/"

file.copy(files, dest_folder, overwrite = TRUE)

