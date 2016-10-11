#!/bin/bash

module load matlab

rm -f finished
echo "starting main.m"
(
nohup time matlab -nodisplay -r main > stdout.log 2> stderr.log
echo $? > finished
) &
