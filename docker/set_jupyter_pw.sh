#!/bin/bash

if [ $# -eq 1 ]; then
    echo "jupyter notebook password: $1"
    jupyter notebook --NotebookApp.token=$1
else
    echo "jupyter notebook password: !dmi00"
    jupyter notebook --NotebookApp.token=!dmi00
fi
