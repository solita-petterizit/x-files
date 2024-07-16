VERSION 0.8
FROM golang:1.22

ARG --global ROOT_DIR="/workspace"
ARG --global APP_DIR="app"
ARG --global BUILD_DIR="build"

WORKDIR $ROOT_DIR

RUN go env -w GOCACHE=/go-cache
RUN go env -w GOMODCACHE=/gomod-cache


all:
    BUILD +test
    BUILD +build
    BUILD +assets

deps:
    COPY ./$APP_DIR/go.mod ./$APP_DIR/go.mod $ROOT_DIR/$APP_DIR
    WORKDIR $ROOT_DIR/$APP_DIR
    RUN --mount=type=cache,target=/go-cache --mount=type=cache,target=/go-modcache go mod download -x

test:
    FROM +deps
    COPY ./$APP_DIR $ROOT_DIR/$APP_DIR
    WORKDIR $ROOT_DIR/$APP_DIR
    RUN go test . -v

build:
    FROM +deps
    WORKDIR $ROOT_DIR
    RUN mkdir -p $ROOT_DIR/$BUILD_DIR
    COPY ./$APP_DIR $ROOT_DIR/$APP_DIR
    ENV GOOS="linux"
    ENV GOARCH="amd64"
    ENV CGO_ENABLED="0"
    RUN cd $ROOT_DIR/$APP_DIR && \
        go build -o "$ROOT_DIR/$BUILD_DIR/app" main.go
    SAVE ARTIFACT --keep-ts $ROOT_DIR/$BUILD_DIR/* $ROOT_DIR/$BUILD_DIR/* AS LOCAL ./$BUILD_DIR/

assets:
    WORKDIR $ROOT_DIR
    RUN mkdir -p $ROOT_DIR/$BUILD_DIR
    COPY ./$APP_DIR/styles.css $ROOT_DIR/$BUILD_DIR
    COPY ./$APP_DIR/index.html $ROOT_DIR/$BUILD_DIR
    SAVE ARTIFACT --keep-ts $ROOT_DIR/$BUILD_DIR/* $ROOT_DIR/$BUILD_DIR/* AS LOCAL ./$BUILD_DIR/

clean:
    LOCALLY
    RUN rm -r ./$BUILD_DIR

docker-build:
    FROM scratch
    ARG TAG="latest"
    COPY ./passwd /etc/passwd
    COPY ./group /etc/group
    USER nobody:nogroup
    COPY +build$ROOT_DIR/$BUILD_DIR/* /
    COPY +assets$ROOT_DIR/$BUILD_DIR/* /
    ENV GIN_MODE=release
    EXPOSE 3000
    ENTRYPOINT ["/app"]
    SAVE IMAGE no-registry.local/hello-world:$TAG

docker-run:
    LOCALLY
    ARG TAG="latest"
    ARG EXPOSED_AT="3000"
    ARG GIN_MODE=""
    IF test "$GIN_MODE" = ""
        WITH DOCKER --load=+docker-build
            RUN docker run -p $EXPOSED_AT:3000 no-registry.local/hello-world:$TAG
        END
    ELSE
        WITH DOCKER --load=+docker-build
            RUN docker run -p $EXPOSED_AT:3000 -e GIN_MODE=$GIN_MODE no-registry.local/hello-world:$TAG
        END
    END

dockerfile:
    ARG TAG="latest"
    FROM DOCKERFILE .
    SAVE IMAGE no-registry.local/hello-world:$TAG

docker:
    BUILD +docker-build
    BUILD +docker-run

docker-dev:
    BUILD +docker-build
    BUILD +docker-run --GIN_MODE="debug"


