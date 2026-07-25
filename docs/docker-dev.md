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
docker run --rm -it -v "$PWD:/workspace" polycpp-dev bash -lc 'cd build && conan install .. --build=missing -pr:b=default -s build_type=Release && cd .. && cmake -S . -B build/Release -G Ninja -DCMAKE_TOOLCHAIN_FILE=build/Release/generators/conan_toolchain.cmake -DPOLYCPP_WARNINGS_AS_ERRORS=ON && cmake --build build/Release && ctest --test-dir build/Release --output-on-failure'
```

## Notes

- `sccache` is preinstalled in the image.
- `POLYCPP_USE_SCCACHE=ON` is the default in this repo.
- Conan-generated preset names can vary by environment and generator (for
  example, `conan-release` vs `conan-default`), so this doc uses explicit
  `-DCMAKE_TOOLCHAIN_FILE=...` configure commands.
- Local `sccache` uses `~/.cache/sccache` by default (no remote configured;
  remote cache configuration is for CI).
- The `dev` user has passwordless sudo for exploratory package installs.

## VS Code devcontainer

Use [.devcontainer/devcontainer.json](.devcontainer/devcontainer.json) and run
the VS Code command: "Dev Containers: Reopen in Container".