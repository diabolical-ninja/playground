#!/bin/bash

cd racing_dates/

for i in $(seq 1192 2 1196)
do
 curl -O http://www.racingnsw.com.au/site/_content/document/0000$i-source.pdf;
done
