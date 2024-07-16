# The directory of this justfile, regardless of current work directory
ROOT_DIR:=justfile_directory()

# Build paths
APP_DIR:=join(ROOT_DIR, "app")
BUILD_DIR:=join(ROOT_DIR, "build")

# Helpers
# No f-strings, yet: https://github.com/casey/just/issues/11#issuecomment-1546877905
IN_APP_DIR:=replace("cd {{APP_DIR}} &&", "{{APP_DIR}}", APP_DIR)

# Go build environment settings
GOOS:="linux"
GOARCH:="amd64"
CGO_ENABLED:="0"

default: test build

@test:
    {{IN_APP_DIR}} go test . -v

@build $GOOS=GOOS $GOARCH=GOARCH $CGO_ENABLED=CGO_ENABLED:
    echo "Ensuring {{BUILD_DIR}} exists"
    @mkdir -p {{BUILD_DIR}}
    echo "Building application ({{APP_DIR}}/main.go) for: {{GOOS}}/{{GOARCH}} (Cgo: {{CGO_ENABLED}})"
    @{{IN_APP_DIR}} go build -o "{{BUILD_DIR}}/app" main.go
    echo "Copying assets from {{APP_DIR}} to {{BUILD_DIR}}"
    @{{IN_APP_DIR}} cp "index.html" "{{BUILD_DIR}}/index.html"
    @{{IN_APP_DIR}} cp "styles.css" "{{BUILD_DIR}}/styles.css"
    echo "Done. Build output:"
    ls -laR "{{BUILD_DIR}}"
    echo "******************************************************"
    echo "Run in debug mode: {{BUILD_DIR}}/app"
    echo "Run in production mode: GIN_MODE=release {{BUILD_DIR}}/app"
    echo "******************************************************"

[confirm]
@clean:
    echo "Deleting {{BUILD_DIR}}"
    @rm -r {{BUILD_DIR}}

# Docker config
# Prevent pushing publicly by accident
DOCKER_REGISTRY:="no-registry.local"
DOCKER_IMAGE:="hello-world"
DOCKER_TAG:="latest"
DOCKER_FULL:=DOCKER_REGISTRY + "/" + DOCKER_IMAGE + ":" + DOCKER_TAG
DOCKER_BUILD_ARGS:=""
EXPOSED_AT:="3000"

docker: docker-build docker-run
docker-dev: docker-build docker-run-dev

docker-build:
	docker build --tag {{DOCKER_FULL}} {{DOCKER_BUILD_ARGS}} .

docker-run:
	docker run -p {{EXPOSED_AT}}:3000 {{DOCKER_FULL}}

docker-run-dev:
	docker run -p {{EXPOSED_AT}}:3000 -e "GIN_MODE=debug" {{DOCKER_FULL}}

