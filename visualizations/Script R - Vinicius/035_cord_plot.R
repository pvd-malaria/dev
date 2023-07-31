rm(list = ls())

xfun::pkg_attach("tidyverse", "readxl", "circlize", "scales")

# Prep plot data --------------------------------------------------------------
mig <- read_csv2("atlas/coord_plot_data.csv.xz") %>%
  # eliminar os autofluxos
  filter(regant != regat,
         fluxo > 2500)

(meta <- mig %>%
    select(uf = regat) %>%
    count(uf) %>%
    mutate(color = c(RColorBrewer::brewer.pal(10, "Set3")),
           rank = 1:10,
           gap = 4))

names(meta$color) <- meta$uf

# Circular plot VOLUME -------------------------------------------------------
options(scipen = 6)

circos.clear()
circos.par(track.margin = c(0.01, -0.01), start.degree = 90, gap.degree = meta$gap)

chordDiagram(x = mig, order = meta$uf,
             grid.col = meta$color,
             transparency = 0.25,
             directional = 1, direction.type = c("diffHeight", "arrows"),
             link.arr.type = "big.arrow", diffHeight = -0.03,
             link.sort = TRUE, link.largest.ontop = TRUE,
             annotationTrack = 'grid',
             annotationTrackHeight = 0.03,
             preAllocateTracks = list(track.height = 0.25))

circos.track(track.index = 1, bg.border = NA, panel.fun = function(x, y) {
  s = get.cell.meta.data("sector.index")
  xx = get.cell.meta.data("xlim")
  circos.text(x = mean(xx), y = 1,
              labels = s, cex = 1, adj = c(0.5, 0),
              facing = "clockwise", niceFacing = TRUE)
  circos.axis(h = "bottom",
              major.at = seq(0, 1100000, 100000),
              labels = number(seq(0, 1100000, 100000), scale = 0.001),
              labels.cex = 0.75,
              labels.pos.adjust = FALSE,
              labels.niceFacing = FALSE)
})
title("Fluxos migratórios, Amazônia Legal, 2000-2010")
text(x = -1.1, y = -1, pos = 4, cex = 1,
     labels = "Em milhares de pessoas")
text(x = 1.5, y = -1, pos = 2, cex = 1,
     labels = "Fonte: IBGE - Censo Demográfico 2010")

# Save the plot --------------------------------------------------------------
dev.print(png,
          file = "atlas/cordas_volume.png",
          width = 10,
          height = 10,
          units = "in",
          res = 500)


# Circular plot RATIO --------------------------------------------------------
options(scipen = 6)

circos.clear()
circos.par(track.margin = c(0.01, -0.01), start.degree = 90, gap.degree = meta$gap)

chordDiagram(x = mig, scale = TRUE,
             order = meta$uf,
             grid.col = meta$color,
             transparency = 0.25,
             directional = 1, direction.type = c("diffHeight", "arrows"),
             link.arr.type = "big.arrow", diffHeight = -0.03,
             link.sort = TRUE, link.largest.ontop = TRUE,
             annotationTrack = 'grid',
             annotationTrackHeight = 0.03,
             preAllocateTracks = list(track.height = 0.25))

circos.track(track.index = 1, bg.border = NA, panel.fun = function(x, y) {
  s = get.cell.meta.data("sector.index")
  xx = get.cell.meta.data("xlim")
  circos.text(x = mean(xx), y = 1,
              labels = s, cex = 1, adj = c(0.5, 0),
              facing = "clockwise", niceFacing = TRUE)
  circos.axis(h = "bottom",
              major.at = seq(0, 2, 0.5),
              labels = number(c(0, 0.25, 0.5, 0.75, NA), accuracy = 0.01),
              labels.cex = 0.75,
              labels.pos.adjust = FALSE,
              labels.niceFacing = FALSE)
})
title("Fluxos migratórios proporcionais, Amazônia Legal, 2000-2010")
text(x = -1.1, y = -1, pos = 4, cex = 1,
     labels = "Em milhares de pessoas")
text(x = 1.5, y = -1, pos = 2, cex = 1,
     labels = "Fonte: IBGE - Censo Demográfico 2010")

# Save the plot --------------------------------------------------------------
dev.print(png,
          file = "atlas/cordas_ratio.png",
          width = 10,
          height = 10,
          units = "in",
          res = 500)
