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

## The point for the rix paper

Pinning R *packages* (with rix/Nix) does not pin the numerical *result*. The draw
depends on the BLAS/LAPACK build underneath, and that is **per-platform**: macOS,
Windows, and Linux each link a different LAPACK, so even with identical package
versions and an identical seed you can get a different number — as macOS does here.

Pinning the linear-algebra layer too (Nix can build BLAS/LAPACK from a pinned
source) buys you bit-identical results only *within the same OS and CPU
architecture*. It does **not** make results identical across macOS / Windows /
Linux, because the compiled library, the compiler, and the hardware floating-point
behaviour still differ. No package or environment manager fixes that across
platforms.

So there are two distinct guarantees:

1. **Same environment, same machine type** -> reproducible. This is what rix/Nix
   delivers, and it covers most reproducibility needs (re-running an analysis,
   CI, a collaborator on the same platform).
2. **Bit-identical across different platforms** -> not guaranteed by pinning at
   all. The robust fix is *algorithmic*: use a numerically stable, sign-flip-
   invariant routine like `mvtnorm::rmvnorm()`, which agrees regardless of the
   LAPACK build (see the `mvtnorm` rows above).
