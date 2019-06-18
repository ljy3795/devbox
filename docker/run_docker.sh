#!/bin/bash
user=colin
user_o_id="$user"_"$(date +%y%m%d_%H%M%S)"

sudo docker run --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES=all --rm -d -p 8888:8888 -e GRANT_SUDO=yes -e JUPYTER_ENABLE_LAB=yes -v /home/colin/docker_home:/home/colin/work --name $user_o_id devbox:0.1 start.sh 'jupyter lab --NotebookApp.token=colin' --restart=always
