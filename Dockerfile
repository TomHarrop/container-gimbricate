FROM ubuntu:22.04

LABEL MAINTAINER "Tom Harrop"
LABEL version=54f7e71

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C

RUN     apt-get clean && \
        rm -r /var/lib/apt/lists/* && \
        apt-get update && apt-get upgrade -y --fix-missing

RUN     apt-get update && apt-get install -y  --no-install-recommends \
            build-essential \
            ca-certificates \
            cmake \
            git \
            zlib1g-dev

RUN     git clone \
            https://github.com/ekg/gimbricate.git \
            /gimbricate

COPY    VERSION /app/VERSION

WORKDIR /gimbricate

RUN     export VERSION=$(cat /app/VERSION) && \
        export TAG="$(expr "$VERSION" : '\([^_]*\)')" && \
        git checkout -f $TAG &&\
        git submodule update --init --recursive

RUN     cmake -H. -Bbuild && cmake --build build --

WORKDIR /gimbricate/build

RUN     make install

WORKDIR /

RUN     rm -rf /gimbricate

ENTRYPOINT ["/usr/local/bin/gimbricate"]
