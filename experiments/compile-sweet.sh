#!/bin/sh

outfile=out.js
sjs --output "$outfile" sweet_experiment.js
cat "$outfile"
