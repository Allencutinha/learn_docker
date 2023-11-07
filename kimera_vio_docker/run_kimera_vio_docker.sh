#! /bin/bash
docker run -itd \
-v /tmp/.X11-unix:/tmp/.X11-unix:rw \
-v $XAUTH:$XAUTH 	\
-e XAUTHORITY=$XAUTH \
-e DISPLAY=$DISPLAY \
--net host \
-v "/etc/group:/etc/group:ro" \
-v "/etc/passwd:/etc/passwd:ro" \
--name vio-docker \
kimera_vio
