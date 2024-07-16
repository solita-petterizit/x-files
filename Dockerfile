#####################
# Build environment #
#####################

FROM golang:1.22 as builder

ENV GOOS=linux
ENV GOARCH=amd64
ENV CGO_ENABLED=0

# Enable caching
RUN go env -w GOCACHE=/go-cache
RUN go env -w GOMODCACHE=/gomod-cache

# Setup workspace
WORKDIR /workspace

COPY ./Makefile /workspace

COPY ./app /workspace/app/

# Build with cache
RUN --mount=type=cache,target=/gomod-cache \
    --mount=type=cache,target=/go-cache \
    make

################
# Distribution #
################

FROM scratch as app

USER nobody

# Setup Linux user
COPY ./passwd /etc/passwd
COPY ./group /etc/group

# Get build artifacts
COPY --from=builder /workspace/build/* /

# Run GIN in release mode by default
ENV GIN_MODE=release

EXPOSE 3000
ENTRYPOINT ["/app"]
