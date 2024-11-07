#!/bin/bash

cat create.sh|grep docker-image|awk '{print $4}' > images.list
echo "kindest/node:v1.31.0" >> images.list

while read line
do
    docker pull $line
done < images.list
