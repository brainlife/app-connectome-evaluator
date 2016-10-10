#!/bin/bash

#return code 0 = running
#return code 1 = finished successfully
#return code 2 = failed
#return code 3 = unknown

##now wait for running to go away
#progress_url={$SCA_PROGRESS_URL}/{$SCA_PROGRESS_KEY}

#TODO I should submit interactive session to run this

if [ -f finished ]; then
    code=`cat finished`
    if [ $code -eq 0 ]; then
        echo "finished successfully"
        exit 1 #success!
    else
        echo "finished with code:$code"
        cat stderr.log
        exit 2 #failed
    fi
fi

echo "assumed to be running"
exit 0

