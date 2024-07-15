# The X-Files

Exploration to the build interfaces of the current day.

Can we leverage some modern solutions to have easy, repeatable, platform-agnostic and maintainable
build environments? Can we perhaps even test them?

## Initial plan

The usual "old skool" ones:

- Script
- Makefile

The commonly referenced modern options:

- Justfile
- Magefile
- Earthfile
- Dagger

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
