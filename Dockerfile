##
## bullet's SIT LINUX Container
## THIS CODE MADE FOR STAY IN TARKOV AND LICENSED UNDER MIT
##

FROM ubuntu:latest AS builder
ARG SIT=
ARG SIT_BRANCH=development
ARG SPT=
ARG SPT_BRANCH=master
ARG NODE=20.11.1

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
WORKDIR /opt

RUN apt update && apt install -yq git git-lfs curl
RUN git clone https://github.com/nvm-sh/nvm.git $HOME/.nvm || true
RUN \. $HOME/.nvm/nvm.sh && nvm install $NODE
RUN git clone --branch $SPT_BRANCH https://dev.sp-tarkov.com/SPT-AKI/Server.git srv || true

WORKDIR /opt/srv/project
RUN git checkout $SPT
RUN git-lfs pull

## remove the encoding from aki - todo: find a better workaround
RUN sed -i '/setEncoding/d' /opt/srv/project/src/Program.ts || true

RUN \. $HOME/.nvm/nvm.sh && npm install && npm run build:release -- --arch=$([ "$(uname -m)" = "aarch64" ] && echo arm64 || echo x64) --platform=linux
RUN mv build/ /opt/server/
WORKDIR /opt
RUN rm -rf srv/
RUN git clone --branch $SIT_BRANCH https://github.com/stayintarkov/SIT.Aki-Server-Mod.git ./server/user/mods/SITCoop
RUN \. $HOME/.nvm/nvm.sh && cd ./server/user/mods/SITCoop && git checkout $SIT && npm install
RUN rm -rf ./server/user/mods/SITCoop/.git

FROM ubuntu:latest
WORKDIR /opt/
RUN apt update && apt upgrade -yq && apt install -yq dos2unix curl
COPY --from=builder /opt/server /opt/srv
COPY ./bullet.sh /opt/bullet.sh
RUN dos2unix /opt/bullet.sh

RUN chmod o+rwx /opt -R

EXPOSE 6969
EXPOSE 6970
EXPOSE 6971

WORKDIR /opt/server
ENTRYPOINT ["/opt/bullet.sh"]
CMD ["./Aki.Server.exe"]
