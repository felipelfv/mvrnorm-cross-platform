# https://blog.djnavarro.net/posts/2025-05-18_multivariate-normal-sampling-floating-point/

cov1 <- matrix(
  c(4.58, -1.07,  2.53,  0.14,
   -1.07,  5.83,  1.15, -1.45,
    2.53,  1.15,  2.26, -0.79,
    0.14, -1.45, -0.79,  4.93),
  nrow = 4, ncol = 4
)
mu <- rep(0, 4)

set.seed(1L)
x_mass <- MASS::mvrnorm(1, mu, cov1)

set.seed(1L)
x_mvt <- as.numeric(mvtnorm::rmvnorm(1, mu, cov1))

# The cause: MASS builds its transform from eigenvectors, whose signs LAPACK
# chooses per-platform, so record them to see which columns flip.
evec <- eigen(cov1, symmetric = TRUE)$vectors

fmt <- function(v) paste(sprintf("%.17g", v), collapse = " ")

writeLines(
  c(
    paste("MASS",    fmt(x_mass)),
    paste("mvtnorm", fmt(x_mvt)),
    paste("evec1",   fmt(evec[, 1])),
    paste("evec2",   fmt(evec[, 2])),
    paste("evec3",   fmt(evec[, 3])),
    paste("evec4",   fmt(evec[, 4]))
  ),
  "result.txt"
)
