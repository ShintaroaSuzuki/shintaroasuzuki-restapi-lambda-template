#!/bin/bash

cd `dirname $0`

exit_code=0

function lintByFile() {
    lines=$(grep -n "type: [^\"].*[^\"]" $1 | sed 's/:.*//g')

    if [ -n "$lines" ]; then
        for line in $lines; do
            echo "[error] type is not quoted line $line in $1"
        done
        exit_code=1
    fi
}

files=$(find . -name '*.yml')

for file in $files; do
    lintByFile $file
done

exit $exit_code
