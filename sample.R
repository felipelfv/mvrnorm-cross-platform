# Same seed, same covariance matrix, one MASS::mvrnorm draw.
# The CI runs this on ubuntu / macos / windows and checks whether the
# four numbers come out identical. See:
# https://blog.djnavarro.net/posts/2025-05-18_multivariate-normal-sampling-floating-point/

cov1 <- matrix(
  c(4.58, -1.07,  2.53,  0.14,
   -1.07,  5.83,  1.15, -1.45,
    2.53,  1.15,  2.26, -0.79,
    0.14, -1.45, -0.79,  4.93),
  nrow = 4, ncol = 4
)

set.seed(1L)
x <- MASS::mvrnorm(1, rep(0, 4), cov1)

cat("Platform:", R.version$platform, "\n")
cat("Values:  ", sprintf("%.17g", x), "\n")

writeLines(paste(sprintf("%.17g", x), collapse = " "), "result.txt")
