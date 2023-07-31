library(googledrive)
library(tidyverse)

path <- as_id("https://drive.google.com/drive/folders/1T8V4OjI2B8Ao-LQHIwE_lILFRo-X57GZ")

driveFiles <- drive_ls(path)

driveFiles <- driveFiles[-nrow(driveFiles), ]
driveFiles

map(driveFiles$id, ~ drive_download(file = as_id(.x), overwrite = T))
