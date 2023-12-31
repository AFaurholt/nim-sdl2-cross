FROM debian:latest AS nimbuild

RUN apt-get update; \
    apt-get install -y wget xz-utils g++; \
    wget -qO- https://deb.nodesource.com/setup_13.x | bash -; \
    apt-get install -y nodejs 
    # buildkits

RUN wget https://nim-lang.org/download/nim-2.0.0.tar.xz; \
    tar xf nim-2.0.0.tar.xz; rm nim-2.0.0.tar.xz; \
    mv nim-2.0.0 nim; \
    cd nim; sh build.sh; \
    rm -r c_code tests; \
    ln -s `pwd`/bin/nim /bin/nim 
    # buildkits

RUN apt-get install -y git mercurial libssl-dev glibc-source
    # buildkits

RUN cd nim; \
    nim c koch; \
    ./koch tools; \
    ln -s `pwd`/bin/nimble /bin/nimble; \
    ln -s `pwd`/bin/nimsuggest /bin/nimsuggest; \
    ln -s `pwd`/bin/testament /bin/testament 
    # buildkits

ENV PATH=/root/.nimble/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

RUN nim --version
RUN nimble --version

FROM nimbuild

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
    libreadline6-dev \
    libncurses5-dev \
    mingw-w64 \
    cmake

# Install other dependencies
RUN apt-get install -y python3-pip git-core unzip zip curl bash

RUN nimble refresh
RUN nimble install nimble@#HEAD
#RUN nimble install nimlangserver@#latest
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
    && tar -xvzf /nimlangserver-linux-amd64.tar.gz -C /root/.nimble/bin/ \
    && rm /nimlangserver-linux-amd64.tar.gz \
    && chown root:root /root/.nimble/bin/nimlangserver
