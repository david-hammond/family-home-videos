#devtools::install_github("R-CoderDotCom/ggbernie@main")
library(ggplot2)
library(magick)
library(ggbernie)
library(cowplot)
library(fs)
output_image_folder = "./data/images/"
try(fs::dir_delete(output_image_folder))
fs::dir_create(output_image_folder)
df = data.frame(x =c(0.57), y = c(0.48))
num_frames = 10
multipliers = 1:num_frames
hjusts = seq(0,0.2, length.out = length(multipliers))
sizes = seq(0.05,0.7, length.out = length(multipliers))
sizes = sizes^3
sizes[length(sizes)] = 25*sizes[length(sizes)] 

num_enter_frames = 2
scales = c(rep(1, num_enter_frames), multipliers, rep(tail(multipliers,1), num_enter_frames))
multipliers = c(rep(0, num_enter_frames), multipliers, rep(tail(multipliers,1), num_enter_frames))
hjusts = c(rep(0, num_enter_frames), hjusts)
sizes = c(rep(0, num_enter_frames), sizes)
for(i in 1:num_enter_frames){
  hjusts = c( hjusts, tail(hjusts,1))
  sizes = c(sizes, tail(sizes,1))
}
count = 0
for (multiplier in multipliers){
  count = count + 1
  my_plot <- 
    ggplot(df, aes (x, y))+ geom_bernie(bernie = "sitting", size = sizes[count]) +
    xlim(c(0,1)) + ylim(c(0,1))+
    theme(axis.line=element_blank(),
          axis.text.x=element_blank(),
          axis.text.y=element_blank(),
          axis.ticks=element_blank(),
          axis.title.x=element_blank(),
          axis.title.y=element_blank(),
          legend.position="none",
          panel.background=element_blank(),
          panel.border=element_blank(),
          panel.grid.major=element_blank(),
          panel.grid.minor=element_blank(),
          plot.background=element_blank())
  p = ggdraw() +
    draw_image("./data/ultrasound.jpg", scale = scales[count], hjust = hjusts[count]) +
    draw_plot(my_plot) 

  fname = paste0(output_image_folder, count,  "ultra.png")
  ggsave(p, filename = fname)
}


## list file names and read in
imgs <- gtools::mixedsort(list.files(output_image_folder, full.names = TRUE))
img_list <- lapply(imgs, image_read)

## join the images together
img_joined <- image_join(img_list)

## animate at 2 frames per second
img_animated <- image_animate(img_joined, fps = 2, optimize = T)

## view animated image
#img_animated

## save to disk
output_gif_folder = "./data/gif/"
try(fs::dir_delete(output_gif_folder))
fs::dir_create(output_gif_folder)
image_write(image = img_animated,
            path = paste0(output_gif_folder, "ultra.gif"))