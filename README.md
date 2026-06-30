# mvrnorm cross-platform check

Reproducing Danielle Navarro's
["When good pseudorandom numbers go bad"](https://blog.djnavarro.net/posts/2025-05-18_multivariate-normal-sampling-floating-point/)
on CI. We run the same `set.seed(1L)` and the same covariance matrix on Linux,
macOS, and Windows GitHub runners, with two samplers, and check whether the draws
agree.

## Results

Same seed, same matrix, across machines:

- `MASS::mvrnorm()` diverges: macOS returns a different vector than Linux and
  Windows. macOS and Windows even use the same LAPACK (reference 3.12.1) and
  still disagree, because the result is decided by the CPU, not just the library.
- `mvtnorm::rmvnorm()` agrees everywhere, unchanged across all three. It uses a
  sign-flip-invariant transform, so the floating-point differences underneath
  don't change the answer.

See the `compare platforms` job in
[Actions](../../actions) for the actual numbers each machine produced.

TODO: use rix and see what happens.
