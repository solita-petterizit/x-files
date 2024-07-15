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

