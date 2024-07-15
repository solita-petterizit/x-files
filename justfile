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

all: test build

test:
    @{{IN_APP_DIR}} go test {{APP_DIR}} -v

build $GOOS=GOOS $GOARCH=GOARCH $CGO_ENABLED=CGO_ENABLED:
    @echo "Ensuring {{BUILD_DIR}} exists"
    @mkdir -p {{BUILD_DIR}}
    @echo "Building application ({{APP_DIR}}/main.go) for: {{GOOS}}/{{GOARCH}} (Cgo: {{CGO_ENABLED}})"
    @{{IN_APP_DIR}} go build -o "{{BUILD_DIR}}/app" main.go
    @echo "Copying assets from {{APP_DIR}} to {{BUILD_DIR}}"
    @{{IN_APP_DIR}} cp "index.html" "{{BUILD_DIR}}/index.html"
    @{{IN_APP_DIR}} cp "styles.css" "{{BUILD_DIR}}/styles.css"
    @echo "Done. Build output:"
    @ls -laR "{{BUILD_DIR}}"
    @echo "******************************************************"
    @echo "Run in debug mode: {{BUILD_DIR}}/app"
    @echo "Run in production mode: GIN_MODE=release {{BUILD_DIR}}/app"
    @echo "******************************************************"

clean:
    @echo "Deleting {{BUILD_DIR}}"
    @rm -r {{BUILD_DIR}}
