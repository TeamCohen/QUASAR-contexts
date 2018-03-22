#!/bin/bash

# SAM: Sample run, or not?
# "sample-" to run for just the first 100 queries
# ""        to run all 40k queries
SAM=sample-

# N: Dry run, or not?
# "n" to just print the command text to the console
# ""  to actually run commands
N=

# K: How many pseudodocuments to retrieve
K=100

set -x
# comment out to disable (don't delete)
SAMPLE=${SAM} MODE=sentencewise JAVARGS=-Dssquad.topk=${K} make -${N}Be ${SAM}sentencewise-output.set $@
SAMPLE=${SAM} MODE=pagewise     JAVARGS=-Dssquad.topk=${K} make -${N}Be ${SAM}pagewise-output.set $@
set +x
