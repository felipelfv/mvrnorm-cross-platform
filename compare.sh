#!/usr/bin/env bash
# Show each tag's value per platform and flag divergence (rounded to 10 sig digits).
set -euo pipefail
for tag in MASS mvtnorm evec1 evec2 evec3 evec4; do
  echo "== $tag =="
  for f in results/*/result.txt; do
    os=$(basename "$(dirname "$f")" | sed 's/^result-//')
    echo "  $os: $(grep "^$tag " "$f" | tr -d '\r' | cut -d' ' -f2-)"
  done
  n=$(grep -h "^$tag " results/*/result.txt | tr -d '\r' | cut -d' ' -f2- \
      | awk '{for(i=1;i<=NF;i++)printf "%.10g ",$i; print ""}' \
      | sort -u | wc -l | tr -d ' ')
  [ "$n" -eq 1 ] && echo "  => MATCH" || echo "  => DIVERGE ($n distinct)"
  echo
done
