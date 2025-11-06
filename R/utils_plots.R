# plotting utility placeholder
library(ggplot2)
library(viridis)
library(cowplot)
library(ggnewscale)

save_wide <- function(p, file, width = 14, height = 6.5, dpi = 600, bg = "white"){
  ensure_dir(dirname(file))
  p_full <- cowplot::ggdraw(p) + theme(plot.background = element_rect(fill = bg, colour = NA))
  ggsave(file, plot = p_full, width = width, height = height, dpi = dpi, bg = bg, limitsize = FALSE)
  message("Saved: ", file)
}

theme_pub <- function(){
  theme_bw(base_size = 13) +
    theme(
      panel.background = element_rect(fill = "white", colour = NA),
      panel.grid = element_line(color = "grey92", linewidth = 0.25),
      plot.title = element_text(size = 15, face = "bold", hjust = 0.5),
      plot.subtitle = element_text(size = 11, hjust = 0.5, margin = margin(b = 8)),
      axis.title = element_text(size = 11, face = "bold"),
      axis.text = element_text(size = 10),
      legend.position = "bottom",
      legend.box = "horizontal",
      legend.justification = "center",
      legend.box.just = "center",
      legend.title = element_text(face = "bold", size = 9, margin = margin(b = 2)),
      legend.text = element_text(size = 8),
      legend.spacing.x = unit(0.5, "cm"),
      legend.spacing.y = unit(0.3, "cm"),
      legend.key.width  = unit(0.9, "cm"),
      legend.key.height = unit(0.4, "cm"),
      legend.background = element_rect(fill = "white", color = "grey80"),
      legend.box.spacing = unit(0.3, "cm"),
      legend.margin = margin(2, 2, 2, 2),
      plot.margin = margin(10, 10, 10, 10)
    )
}
