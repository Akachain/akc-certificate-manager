#!/bin/bash

function printHelp() {
    echo "Usage:"
    echo "  main.sh <Function>"
    echo "    <Function>"
    echo "      - 'checker' - Check certificate"
    echo "      - 'generate' - Generate certificate"
}

ACTION=$1
shift
if [ "$ACTION" == "checker" ]; then
    . scripts/checker.sh
elif [ "$ACTION" == "generate" ]; then
    . scripts/generate.sh
else
    printHelp
fi