library(raster)
library(sf)
library(RColorBrewer)
library(grid)
library(gridExtra)

# input files
indir <- "data"

# raster for Kenya
r <- file.path(indir, "onset_2020_2020-04-03_raster.tif")
r <- stack(r)

# vector for selected wards
v <- file.path(indir, "onset_2020_2020-04-03_vector.rds")
v <- readRDS(v)
st_write(st_as_sf(v), file.path(indir, "onset_2020_2020-04-03_vector.geojson"))

# table for selected wards
ds <- file.path(indir, "onset_2020_2020-04-03_table.csv")
ds <- read.csv(ds, stringsAsFactors = FALSE)

# kenya boundary
v0 <- getData(name = "GADM", country = "KEN", level = 0, path = indir)

# input parameters
year <- 2020
sos <- '-02-15'
eos <- '-05-31'

#####################################################################################
# make maps
cols <- brewer.pal(9, "Blues")
pal <- colorRampPalette(cols)

poly0 <- list("sp.polygons", v0)
poly3 <- list("sp.polygons", v, fill = "grey50", col = NA)

# show calendar date in legend
sdate <- lubridate::ymd(paste0(year, sos))
labelat <- seq(min(v$onset), max(v$onset), 3)
origin <- lubridate::ymd(paste0(year,"-01-01"))
labeltext <- origin + labelat
labeltext <- format(labeltext, "%d-%b-%y") 


##################################################################################
# arrange plots
outdir <- file.path(indir, "img/")
outfile <- paste0(outdir, "/onset_", year, "_", Sys.Date())

# Save plot
png(paste0(outfile, "_map.png"), width = 8, height = 5, units = "in", res = 300)


p1 <- spplot(as(v0, "SpatialPolygons"), 
             sp.layout = list(poly3), 
             col.regions = "transparent",
             colorkey = FALSE)

p2 <- spplot(v, "onset",
             # sp.layout = poly,
             # xlim = bbox(v0)[1, ],
             # ylim = bbox(v0)[2, ],
             col = "grey60",
             col.regions=pal(30), 
             colorkey = list(width = 0.75, height = 0.75, space="bottom",
                             labels=list(
                               at = labelat,
                               labels = labeltext,
                               cex = 0.75,
                               rot = 60)
             ),
             par.settings=list(fontsize=list(text=10)))

text <- textGrob(paste0("Date of onset in the focus regions",
                        "\nStart of season ", sdate,
                        "\nDate of analysis ", Sys.Date()),
                 gp = gpar(fontface = 3, fontsize = 9))

# slightly complicated matrix to make the Kenya plot smaller and wards larger
lay <- rbind(c(1,3,3),
             c(2,3,3))

grid.arrange(text, p1, p2, layout_matrix = lay)

dev.off()