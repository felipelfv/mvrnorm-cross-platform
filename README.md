# mvrnorm cross-platform check

A minimal CI experiment that checks whether multivariate-normal sampling in R is
reproducible across operating systems. It runs the **same seeded** sampling call
on `ubuntu-latest`, `macos-latest`, and `windows-latest` GitHub runners, hashes
each result, and fails/flags if the platforms disagree.

Motivation: Danielle Navarro,
[*Reproducibility, multivariate normal sampling, and floating point*](https://blog.djnavarro.net/posts/2025-05-18_multivariate-normal-sampling-floating-point/).

## What it shows

`MASS::mvrnorm()` builds its transformation matrix from an eigendecomposition,
`A = Lambda^(1/2) Q'`. Tiny floating-point differences between LAPACK/BLAS builds
can flip the **sign of an eigenvector**, which changes `A` entirely. So even with
an identical `set.seed()` and an identical covariance matrix, two machines can
draw completely different vectors.

The fix is a sign-flip-invariant transform:

- `mvtnorm::rmvnorm()` uses `A = Q Lambda^(1/2) Q'` (default `method = "eigen"`)
- `mvtnorm::rmvnorm(..., method = "chol")` uses the Cholesky factor

Both should agree across platforms; `MASS::mvrnorm()` is the one that can diverge.

## How it works

- [`sample.R`](sample.R) draws one sample with each method and writes a sha256
  fingerprint per method to `result.txt`.
- [`.github/workflows/cross-platform.yml`](.github/workflows/cross-platform.yml)
  runs `sample.R` on three OSes (matrix), uploads each `result.txt`, then a
  `compare` job checks whether the fingerprints match and writes a summary.

Whether `MASS::mvrnorm()` actually diverges depends on the LAPACK build each
runner ships, which is the entire point: pinning R *packages* does not pin the
numerical *result* unless the linear-algebra layer underneath is pinned too.

Run it from the Actions tab (workflow_dispatch) or just push.
