# same seed, same covariance matrix, two samplers:
# MASS::mvrnorm()    - eigendecomposition transform, can flip across platforms
# mvtnorm::rmvnorm() - sign-flip-invariant transform, should agree everywhere
# the ci runs this on ubuntu / macos / windows and checks each for agreement.
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

cat("Platform:", R.version$platform, "\n")
cat("MASS::mvrnorm:    ", sprintf("%.17g", x_mass), "\n")
cat("mvtnorm::rmvnorm: ", sprintf("%.17g", x_mvt), "\n")

writeLines(
  c(
    paste("MASS",    paste(sprintf("%.17g", x_mass), collapse = " ")),
    paste("mvtnorm", paste(sprintf("%.17g", x_mvt),  collapse = " "))
  ),
  "result.txt"
)
