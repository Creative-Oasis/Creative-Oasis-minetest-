#!/usr/bin/env bash
grep $(date -u -I) modpack.conf &&
    grep $(date -u -I) invsaw/mod.conf &&
    grep $(date -u -I) moreblocks/mod.conf &&
    grep $(date -u -I) moreblocks_legacy_recipes/mod.conf &&
    grep $(date -u -I) stairs/mod.conf &&
    grep $(date -u -I) stairsplus/mod.conf &&
    grep $(date -u -I) stairsplus_legacy/mod.conf
exit $?
