#!/bin/bash

echo "running on " `hostname`

#allows test execution
if [ -z $SCA_SERVICE_DIR ]; then
    export SCA_SERVICE_DIR=`pwd`
fi
if [ -z "$SCA_PROGRESS_URL" ]; then
    export SCA_PROGRESS_URL="https://soichi7.ppa.iu.edu/api/progress/status/_sca.test"
fi

export MATLABPATH=$MATLABPATH:$SCA_SERVICE_DIR
module load matlab
#echo $MATLABPATH

echo "now running matlab"
nohup time matlab -nodisplay -r main > stdout.log 2> stderr.log &

