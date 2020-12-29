library(tidyverse)
library(tools)
library(lubridate)
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
  seconds = lubridate::period_to_seconds( lubridate::hms(splits$to[i]) - lubridate::hms(splits$from[i]))
  comd = paste("ffmpeg -ss", splits$from[i], "-i", splits$file[i],  
               "-t ", seconds, #"-c copy ",
               "-vcodec copy -acodec copy -avoid_negative_ts make_zero", 
               paste(new_folder, splits$fname[i], sep = "/"))
  #for some reason ffmpeg parameter order makes a difference as per
  #https://video.stackexchange.com/questions/18284/cutting-with-ffmpeg-results-in-few-seconds-of-black-screen-how-do-i-fix-this
  print(comd)
  system(comd)
}
