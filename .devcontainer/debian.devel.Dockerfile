FROM debian:latest AS buildnim

WORKDIR /

RUN apt-get update && apt-get install -y \
    git \
    gcc \
    make \
    wget

RUN git clone --single-branch --branch devel https://github.com/nim-lang/Nim.git
RUN cd Nim; ./build_all.sh

ENV PATH="$PATH:/Nim/bin"

RUN nim -v
RUN nimble -v

RUN nimble refresh
RUN nimble install nimble@#HEAD

FROM buildnim AS buildlsp

WORKDIR /

RUN apt-get install -y python3-pip git-core unzip zip curl bash

RUN apt install make libreadline-dev libghc-bzlib-dev libz-dev libbz2-dev autoconf bzip2 -y
RUN cd /opt && mkdir pcre && cd pcre && git clone https://github.com/luvit/pcre.git . \
    && ./configure --prefix=/usr              \
            --docdir=/usr/share/doc/pcre-8.45 \
            --enable-unicode-properties       \
            --enable-pcre16                   \
            --enable-pcre32                   \
            --enable-pcregrep-libz            \
            --enable-pcregrep-libbz2          \
            --enable-pcretest-libreadline     \
            --disable-static                  \
    && make \
    && make install 
RUN cd /opt && rm -r -f pcre

RUN wget https://github.com/nim-lang/langserver/releases/download/latest/nimlangserver-linux-amd64.tar.gz \
    && tar -xzf /nimlangserver-linux-amd64.tar.gz -C /root/.nimble/bin/ \
    && rm /nimlangserver-linux-amd64.tar.gz \
    && chown root:root /root/.nimble/bin/nimlangserver

FROM buildlsp AS sdlbuild

#https://dev.to/setevoy/docker-configure-tzdata-and-timezone-during-build-20bk
ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apt-get install -y tzdata
RUN apt-get install -y \
    gcc \
    g++ \
    gcc-multilib \
    g++-multilib \
    build-essential \
    xutils-dev \
    libsdl2-dev \
    libsdl2-gfx-dev \
    libsdl2-image-dev \
    libsdl2-mixer-dev \
    libsdl2-net-dev \
    libsdl2-ttf-dev \
    libsdl2-2.0-0 \
    libsdl2-gfx-1.0-0 \
    libsdl2-image-2.0-0 \
    libsdl2-mixer-2.0-0 \
    libsdl2-net-2.0-0 \
    libsdl2-ttf-2.0-0 \
    libreadline6-dev \
    libncurses5-dev \
    mingw-w64 \
    cmake