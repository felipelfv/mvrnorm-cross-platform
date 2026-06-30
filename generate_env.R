# "Why risk it when you can rix it": pin R + MASS + mvtnorm via Nix so every
# runner gets byte-identical packages. If MASS still diverges, the cause is the
# CPU, not the software stack.
library(rix)

rix(
  r_ver = "2026-06-15",
  r_pkgs = c("MASS", "mvtnorm"),
  ide = "none",
  project_path = ".",
  overwrite = TRUE,
  print = TRUE
)
