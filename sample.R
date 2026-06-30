# Reproduces the cross-platform sampling issue from
# https://blog.djnavarro.net/posts/2025-05-18_multivariate-normal-sampling-floating-point/
#
# Same seed, same covariance matrix, three sampling routines. We fingerprint
# each result with sha256 and let the CI `compare` job check whether the
# fingerprints agree across ubuntu / macos / windows runners.
#
# Expectation:
#   - MASS::mvrnorm()  can DIVERGE across platforms (eigenvector sign flips
#                      under different LAPACK/BLAS builds, despite identical seed)
#   - mvtnorm::rmvnorm() and the Cholesky method are sign-flip invariant and
#                      should AGREE everywhere.

cov1 <- matrix(
  c(4.58, -1.07,  2.53,  0.14,
   -1.07,  5.83,  1.15, -1.45,
    2.53,  1.15,  2.26, -0.79,
    0.14, -1.45, -0.79,  4.93),
  nrow = 4, ncol = 4
)
mu <- rep(0, 4)

fingerprint <- function(x) digest::digest(round(x, 12), algo = "sha256")

set.seed(1L)
x_mass <- MASS::mvrnorm(1, mu, cov1)

set.seed(1L)
x_mvtnorm <- mvtnorm::rmvnorm(1, mu, cov1)                   # default "eigen" (Q Lambda^.5 Q'), sign-flip invariant

set.seed(1L)
x_chol <- mvtnorm::rmvnorm(1, mu, cov1, method = "chol")     # Cholesky, unique up to sign of diagonal

lines <- c(
  paste("MASS_mvrnorm",    fingerprint(x_mass)),
  paste("mvtnorm_rmvnorm", fingerprint(x_mvtnorm)),
  paste("mvtnorm_chol",    fingerprint(x_chol))
)

cat("Platform:", R.version$platform, "\n")
cat("R version:", R.version.string, "\n")
cat("Values (MASS::mvrnorm):", sprintf("%.17g", x_mass), "\n")
cat(lines, sep = "\n")
cat("\n")

writeLines(lines, "result.txt")
