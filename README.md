# mvrnorm cross-platform check

Does a **seeded** multivariate-normal draw come out the same on Linux, macOS, and
Windows? This runs the same `set.seed()` + same covariance matrix on all three
GitHub runners with two samplers and reports the numbers each produced plus whether
they match:

- `MASS::mvrnorm()` — eigendecomposition transform; **diverges** (macOS flips).
- `mvtnorm::rmvnorm()` — sign-flip-invariant transform; **agrees** everywhere. The fix.

Motivation: Danielle Navarro,
[*Reproducibility, multivariate normal sampling, and floating point*](https://blog.djnavarro.net/posts/2025-05-18_multivariate-normal-sampling-floating-point/).
`MASS::mvrnorm()` builds its transform from an eigendecomposition, and tiny
floating-point differences between LAPACK/BLAS builds can flip an eigenvector's
sign, changing the result even though the seed is identical.

- [`sample.R`](sample.R) draws the sample and writes the values to `result.txt`.
- [`.github/workflows/cross-platform.yml`](.github/workflows/cross-platform.yml)
  runs it on `ubuntu-latest`, `macos-latest`, `windows-latest`, then a `compare`
  job prints each platform's values and flags a divergence.

This is the point for the rix paper: pinning R *packages* does not pin the
numerical *result* unless the linear-algebra layer underneath is pinned too.
