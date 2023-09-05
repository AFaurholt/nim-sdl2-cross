FROM alpine:3.17 as builder

RUN apk add git gcc musl-dev

WORKDIR /build

RUN git clone https://github.com/nim-lang/Nim.git

COPY curtag Nim

RUN cd Nim && git checkout -f $(cat curtag)

WORKDIR /build/Nim

RUN git clone "https://github.com/nim-lang/csources_$(cat curtag | head -c 2).git" csources

WORKDIR /build/Nim/csources

RUN ls
RUN pwd

COPY curtag .

RUN git checkout -f $(cat curtag) || git checkout -f $(echo $(git tag) $(cat curtag) | sed 's/ /\n/g' | sed 's/v/0./' | sort -t. -n -k1,1 -k2,2 -k3,3 -k4,4 | sed 's/0./v/' | sed -n "/$(cat curtag)/q;p" | tail -n1)

RUN sh build.sh

WORKDIR /build/Nim

RUN bin/nim c --skipUserCfg --skipParentCfg koch

RUN ./koch boot -d:release

RUN mkdir /build/result

RUN ./koch install /build/result

RUN ./koch nimble

##################################

FROM alpine:3.17 as installer

RUN apk add git gcc musl-dev libressl-dev

COPY --from=builder /build/result/* ./nim/

COPY --from=builder /build/Nim/bin/nimble ./nim/bin

ENV PATH=$PATH:/nim/bin

RUN nimble --version

##################################
FROM installer

ENV PATH=$PATH:/nim/bin

RUN nim --version
RUN nimble --version

#https://dev.to/setevoy/docker-configure-tzdata-and-timezone-during-build-20bk
ENV TZ=Etc/UTC
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone
RUN apk add \
    gcc \
    g++ \
    sdl2-dev \
    sdl2_gfx-dev \
    sdl2_image-dev \
    sdl2_mixer-dev \
    sdl2_net-dev \
    sdl2_ttf-dev \
    readline \
    ncurses-dev \
    mingw-w64-gcc \
    cmake

# Install other dependencies
RUN apk add py3-pip git unzip zip curl bash
