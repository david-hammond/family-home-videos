#devtools::install_github("R-CoderDotCom/ggbernie@main")
library(ggplot2)
library(magick)
library(ggbernie)
library(cowplot)
library(fs)
output_image_folder = "./data/images/"
try(fs::dir_delete(output_image_folder))
fs::dir_create(output_image_folder)

#Parameters
screen_size = 2
num_enter_frames = 10
df = data.frame(x =c(0.57), y = c(0.48))
num_frames = 40
final_bernie = 1.2*screen_size
penultimate_bernie = 0.35*final_bernie
#calculate parameters
scales = 1:num_frames
hjusts = seq(0,0.2, length.out = length(scales ))
sizes = seq(0.05,penultimate_bernie, length.out = length(scales ))
sizes = sizes^3
sizes[length(sizes)] = final_bernie
scales = c(rep(1, num_enter_frames), scales, rep(tail(scales ,1), num_enter_frames))
hjusts = c(rep(0, num_enter_frames), hjusts)
sizes = c(rep(0, num_enter_frames), sizes)
for(i in 1:(2*num_enter_frames)){
  hjusts = c( hjusts, tail(hjusts,1))
  sizes = c(sizes, tail(sizes,1))
}
count = 0
for (i in scales){
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
  ggsave(p, filename = fname, width = screen_size, height = screen_size)
}


## list file names and read in
imgs <- gtools::mixedsort(list.files(output_image_folder, full.names = TRUE))
img_list <- lapply(imgs, image_read)

#annotated
img_list = lapply(img_list, image_annotate, text = "Zoom In",  size = 50, 
                  gravity = "north", color = "grey")

## join the images together
img_joined <- image_join(img_list)

## animate at 2 frames per second
img_animated <- image_animate(img_joined, fps = 10, optimize = T)

## view animated image
#img_animated

## save to disk
output_gif_folder = "./data/gif/"
try(fs::dir_delete(output_gif_folder))
fs::dir_create(output_gif_folder)
image_write(image = img_animated,
            path = paste0(output_gif_folder, "ultra.gif"))



system('ffmpeg -i ./data/gif/ultra.gif -movflags faststart -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" ./data/gif/ultra.mp4')

