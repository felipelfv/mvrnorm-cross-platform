# Overlay each platform's marginal densities. One panel per dimension, one
# colored curve per platform. Overlapping curves mean the distribution is the
# same even where the per-draw numbers diverge.
dirs <- list.files("draws", full.names = TRUE)
data <- list()
for (d in dirs) {
  f <- file.path(d, "draws.csv")
  if (!file.exists(f)) next
  lab <- sub(".*draws-native-", "", basename(d))
  data[[lab]] <- as.matrix(read.csv(f, header = FALSE))
}

labs <- names(data)
cols <- c("#1b9e77", "#d95f02", "#7570b3")[seq_along(labs)]

png("densities.png", width = 1000, height = 800, res = 110)
par(mfrow = c(2, 2), mar = c(4, 4, 2, 1))
for (j in 1:4) {
  dens <- lapply(data, function(m) density(m[, j]))
  xr <- range(sapply(dens, function(z) range(z$x)))
  yr <- range(sapply(dens, function(z) range(z$y)))
  plot(NA, xlim = xr, ylim = yr, xlab = paste("dim", j), ylab = "density",
       main = paste("marginal", j))
  for (i in seq_along(dens)) lines(dens[[i]], col = cols[i], lwd = 2)
  if (j == 1) legend("topright", legend = labs, col = cols, lwd = 2, bty = "n")
}
dev.off()
