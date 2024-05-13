#!/bin/bash
### THIS CODE MADE FOR STAY IN TARKOV AND LICENSED UNDER MIT

SIT_VERSION="${SIT:=latest}"
HEADLESS="${HEADLESS:-}"
FORCE="${FORCE:-}"
BACKENDIP="${BACKENDIP:=$(curl -s4 ipv4.icanhazip.com)}"
echo "Stay In Tarkov Docker"
echo "github.com/StayInTarkov"

if [ ! -e "/opt/server/version" ] || [ ! -z "$FORCE" ]; then
  if [ -d "/opt/srv" ]; then
    start=$(date +%s)
    echo "Started copying files to your volume/directory.. Please wait."
    cp -r /opt/srv/* /opt/server/
    rm -r /opt/srv
    end=$(date +%s)
    echo "Files copied to your machine in $(($end-$start)) seconds."
    echo "Starting the server to generate all the required files.. Please wait."
    cd /opt/server
    chown $(id -u):$(id -g) ./* -Rf
    sed -i 's/\"ip\": \"127.0.0.1\"/\"ip\": \"0.0.0.0\"/g' ./Aki_Data/Server/configs/http.json
    sed -i "s/\"backendIp\": \"127.0.0.1\"/\"backendIp\": \"$BACKENDIP\"/g" ./Aki_Data/Server/configs/http.json
    NODE_CHANNEL_FD= timeout 40s ./Aki.Server.exe </dev/null >/dev/null 2>&1
    echo "Version $SIT_VERSION is set to ./server/version"
    echo "$SIT_VERSION" > /opt/server/version
    if [ -z "$HEADLESS" ]; then
      echo "SIT.Docker setup is now complete!"
      echo "You can configure and start your container."
      exit 0
    fi
  fi
else
  SIT_VERSION=$(cat /opt/server/version)
  echo "./server/version ($SIT_VERSION) file found, use -e FORCE=y if updating"
fi
exec "$@"
