#!/bin/bash

docker build . -t netlife/pbx
docker stop freepbx2
docker rm freepbx2
docker run --net=host --name freepbx2  -d -t netlife/PBX
docker exec -it freepbx2 bash


