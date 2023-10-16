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
RUN nimble install nimble@HEAD

FROM buildnim AS buildlsp

WORKDIR /

RUN wget https://github.com/nim-lang/langserver/releases/download/latest/nimlangserver-linux-amd64.tar.gz \
    && tar -xzf /nimlangserver-linux-amd64.tar.gz -C /root/.nimble/bin/ \
    && rm /nimlangserver-linux-amd64.tar.gz \
    && chown root:root /root/.nimble/bin/nimlangserver