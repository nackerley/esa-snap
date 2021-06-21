#!/bin/bash

# Local directory
image=esa-snap/ubuntu:latest
echo "Image: $image"
container_user="root"
container_mount="type=bind,source=$PWD,target=$PWD"
echo "Mount: $container_mount"

# Allow docker (running as root) to connect to local X server
xhost +local:root &> /dev/null

# Change permissions for .Xauthority file
chmod a+r $HOME/.Xauthority

# Check permissions for directory to be mounted inside container
host_permissions=$(stat -c "%A" .)
if ! [[ ${host_permissions:7:1} == "r" ]]; then
  echo "Consider granting read access to container: chmod a+r $PWD"
fi
if ! [[ ${host_permissions:8:1} == "w" ]]; then
  echo "Consider granting write access to container: chmod a+w $PWD"
fi

echo "Starting docker with X11 support ..."
docker run --interactive --tty --rm \
    --net host \
    --env "QT_GRAPHICSSYSTEM=native" \
    --env "QT_X11_NO_MITSHM=1" \
    --env DISPLAY \
    --mount type=bind,source=$HOME/.Xauthority,target=/$container_user/.Xauthority \
    --mount $container_mount \
	--user root \
	$image

# Remove X server
xhost -local:root &> /dev/null
