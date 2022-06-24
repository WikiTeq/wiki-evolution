# https://hub.docker.com/_/node?tab=tags&page=1&name=slim
FROM node:slim

RUN apt-get update && \
	apt-get install -y ffmpeg xvfb vim && \
    apt-get install -y vim autoconf automake git build-essential libsdl2-dev libsdl2-image-dev libpcre2-dev libfreetype6-dev libglew-dev libglm-dev libboost-filesystem-dev libpng-dev libtinyxml-dev

WORKDIR /opt/wiki-evolution

RUN git clone https://github.com/WikiTeq/Gource.git && \
    cd Gource && \
    ./autogen.sh && \
    ./configure && \
    make && \
    make install

COPY package.json .
COPY package-lock.json .
RUN npm ci

# these two are passed as build args
ARG BUILD_DATE
ARG GITHUB_SHA
ENV BUILD_DATE=$BUILD_DATE
ENV GITHUB_SHA=$GITHUB_SHA

COPY . .
#COPY ./gource /bin/gource
#RUN chmod +x /bin/gource
USER root
