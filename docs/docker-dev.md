# Docker Development Environment

This image provides a reproducible Ubuntu 24.04 developer environment that
matches the local and CI toolchain expectations for this repository.

## Build the image

```bash
docker build -t polycpp-dev -f Dockerfile.dev .
```

## Run interactively with your workspace mounted

```bash
docker run --rm -it -v "$PWD:/workspace" polycpp-dev
```

## Run a one-shot configure/build/test flow

```bash
docker run --rm -it -v "$PWD:/workspace" polycpp-dev bash -lc 'cd build && conan install .. --build=missing -pr:b=default -s build_type=Release && cd .. && cmake --preset conan-release -DPOLYCPP_WARNINGS_AS_ERRORS=ON && cmake --build build/Release && ctest --test-dir build/Release --output-on-failure'
```

## Notes

- `sccache` is preinstalled in the image.
- `POLYCPP_USE_SCCACHE=ON` is the default in this repo.
- Local `sccache` uses `~/.cache/sccache` by default (no remote configured;
  remote cache configuration is for CI).
- The `dev` user has passwordless sudo for exploratory package installs.

## VS Code devcontainer

Use [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) and run
the VS Code command: "Dev Containers: Reopen in Container".