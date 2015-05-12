#!/bin/bash

# Update folder structure

JMETER_PATH="/Users/hemikakodikara/mb/clients/mb-jmeter/bin"
PROJECT_PATH="\/Users\/hemikakodikara\/mb\/workspace\/jmeter-jms-performance-shell"

function setPaths () {
    local OLD_PATH="%%ProjPath%%"
    find ./jmx/ -name '*.jmx' -exec sed -i '' "s/$OLD_PATH/$PROJECT_PATH/g" "{}" \;
}

function clearOutputFolder () {
    rm ./output/logs/*
    rm ./output/nohups/*
    rm ./output/reports/*
}

function waitTillFileSizeChange () {
    local OLD_SIZE=-1
    local NEW_SIZE=0
    while [[ ${OLD_SIZE} != ${NEW_SIZE} ]]
    do
        echo "Waiting..."
        sleep 5
        OLD_SIZE=${NEW_SIZE}
        NEW_SIZE=$(stat -f %z $1)
        echo $1, SIZE : ${NEW_SIZE}
    done
}

function main () {
    echo "Test Started."

    local FILES=./jmx/$1/*
    local SUBSCRIBER_PATH
    local PUBLISHER_PATH
    for f in ${FILES}
    do
        if [[ ${f} == *"Subscriber"* ]]
        then
            SUBSCRIBER_PATH=${f}
        else
            PUBLISHER_PATH=${f}
        fi
    done

    local SUB_FILENAME="${SUBSCRIBER_PATH##*/}"
    local SUB_FILENAME="${SUB_FILENAME%.*}"

    local PUB_FILENAME="${PUBLISHER_PATH##*/}"
    local PUB_FILENAME="${PUB_FILENAME%.*}"

    nohup "$JMETER_PATH/jmeter.sh" -n -t ${SUBSCRIBER_PATH} -l "./output/reports/${SUB_FILENAME}.jtl" -j "./output/logs/${SUB_FILENAME}.log" > "./output/nohups/${SUB_FILENAME}.out" &

    echo "Waiting for subscriber to subscribe..."

    sleep 5

    nohup "$JMETER_PATH/jmeter.sh" -n -t ${PUBLISHER_PATH} -l "./output/reports/${PUB_FILENAME}.jtl" -j "./output/logs/${PUB_FILENAME}.log" > "./output/nohups/${PUB_FILENAME}.out" &

    waitTillFileSizeChange "./output/reports/${PUB_FILENAME}.jtl"
    echo "Publisher finished."

    waitTillFileSizeChange "./output/reports/${SUB_FILENAME}.jtl"
    echo "Subscriber finished."

    ${JMETER_PATH}/shutdown.sh

    sleep 3

    kill -SIGTERM $(ps -ef | grep jmeter | grep -v 'grep' | awk '{print $2}')

    echo "Test finished."
}

setPaths

clearOutputFolder

main 1KB/1Thread
main 1KB/2Thread
main 1KB/5Thread
main 1KB/10Thread

main 5KB/1Thread
main 5KB/2Thread
main 5KB/5Thread
main 5KB/10Thread

main 1KB/1Thread
main 5KB/2Thread
main 5KB/5Thread
main 5KB/10Thread

exit
