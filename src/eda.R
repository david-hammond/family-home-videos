library(tidyverse)
library(tools)
splits = rio::import("./data/video-splits.ods", which = 1)
splits$uid = 1:nrow(splits)
splits$fname = paste(splits$uid, gsub(" ", "-", tolower(splits$title)), sep = "-")
splits$fname = paste0(splits$fname, ".mp4")
new_folder = paste(dirname(splits$file[1]), 
                   tolower(file_path_sans_ext(basename(splits$file[1]))), sep = "/")
if(dir.exists(new_folder)){
  f <- list.files(new_folder, include.dirs = T, full.names = T, recursive = T)
  file.remove(f)
}else{
  dir.create(new_folder)
}
for (i in 1:nrow(splits)){
  comd = paste("ffmpeg -i", splits$file[i],  "-ss", splits$from[i], "-to", splits$to[i], 
               "-acodec copy \ -vcodec copy ", paste(new_folder, splits$fname[i], sep = "/"))
  print(comd)
  system(comd)
}