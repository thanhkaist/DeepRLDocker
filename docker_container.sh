#!/usr/bin/env bash

NAME=deep_rl_v10
LOCAL_WORKSPACE=$HOME/workspace
if hash nvidia-docker 2>/dev/null; then
  cmd=nvidia-docker
else
  cmd=docker
fi

${cmd} run --net=host -d -it --name ${NAME} -v ${LOCAL_WORKSPACE}:/home/user/workspace deep_rl:v1.10