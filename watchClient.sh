#!bin/sh
$1 client
while [ 1 = 1 ]
do
    inotifywait -e modify client/src/* client/css/stylus/*
    $1 client
    echo modified
done