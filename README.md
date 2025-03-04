# The X-Files

Exploration to the build interfaces of the current day.

Can we leverage some modern solutions to have easy, repeatable, platform-agnostic and maintainable
build environments? Can we perhaps even test them?

## Initial plan

The usual "old skool" ones:

- [x] Script
- [x] Makefile

The commonly referenced modern options:

- [x] Justfile
- [x] Magefile
- [x] Earthfile
- [x] Dagger

## Development (Linux)

### Shell-driven

1. Test: `./scripts/test.sh`
2. Build: `./scripts/build-linux.sh`
3. Remove build artifacts: `./scripts/clean.sh`

### Makefile

1. Test and build: `make`

or:

1. Test: `make test`
2. Build: `make build`
3. Remove build artifacts: `make clean`

#### Docker workflow

1. Build and run: `make docker[-dev]`

or:

1. Build: `make docker-build`
2. Run: `make docker-run[-dev]`

### Justfile

#### Pre-requisites

1. [Install just](https://github.com/casey/just/tree/master?tab=readme-ov-file#installation)

E.g x86_64 binary:

```sh
wget https://github.com/casey/just/releases/download/1.31.0/just-1.31.0-x86_64-unknown-linux-musl.tar.gz
tar xvf just-1.31.0-x86_64-unknown-linux-musl.tar.gz --directory=/usr/local/bin just
```

#### Usage

1. Test and build: `just`

or:

1. Test: `just test`
2. Build: `just build`
3. Remove build artifacts: `just clean`

#### Docker workflow

1. Build and run: `just docker[-dev]`

or:

1. Build: `just docker-build`
2. Run: `just docker-run[-dev]`

### Taskfile

#### Pre-requisites

1. [Install task](https://taskfile.dev/installation/)

E.g x86_64 binary:

```sh
wget https://github.com/go-task/task/releases/download/v3.38.0/task_linux_amd64.tar.gz
tar xvf task_linux_amd64.tar.gz --directory=/usr/local/bin task
```

#### Usage

1. Test and build: `task`

or:

1. Test: `task test`
2. Build: `task build`
3. Remove build artifacts: `task clean`

#### Docker workflow

1. Build and run: `task docker[-dev]`

or:

1. Build: `task docker-build`
2. Run: `task docker-run[-dev]`

### Magefile

#### Pre-requisites

1. [Install mage](https://magefile.org/)

E.g as using Go modules:

```sh
git clone https://github.com/magefile/mage
cd mage
go run bootstrap.go
```

#### Usage

1. Test and build: `mage`

or:

1. Test: `mage test`
2. Build: `mage build`
3. Remove build artifacts: `mage clean`

#### Docker workflow

1. Build and run: `mage docker[Dev]`

or:

1. Build: `mage dockerBuild`
2. Run: `mage dockerRun[Dev]`

### Earthfile

#### Pre-requisites

1. [Install earthly](https://earthly.dev/get-earthly)
2. Disable analytics by adding the following in `~/.earthly/config.yml` (create it if it does not exist):

```yml
global:
    disable_analytics: true
```

#### Usage

1. Test and build: `earthly +all`

or:

1. Test: `earthly +test`
2. Build: `earthly +build`
3. Remove build artifacts: `earthly +clean`

#### Docker workflow

1. Build and run: `earthly +docker[-dev]`

or:

1. Build: `earthly +docker-build` or `earthly +dockerfile`
2. Run: `earthly +docker-run[-dev]`

