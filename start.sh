#!/bin/bash

#allows test execution
if [ -z $SERVICE_DIR ]; then export SERVICE_DIR=`pwd`; fi
if [ -z $ENV ]; then export ENV=IUHPC; fi

rm -f finished

if [ $ENV == "IUHPC" ]; then
	module load matlab
fi

echo "starting main"

(
export MATLABPATH=$MATLABPATH:$SERVICE_DIR
nohup time matlab -nodisplay -r main > stdout.log 2> stderr.log

if [ -s out.json ];
then
	echo 0 > finished
else
	echo "out.json missing"
	echo 1 > finished
	exit 1
fi
) &
