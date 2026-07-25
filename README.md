# polycpp-template

polycpp-template is a reusable monorepo template for orchestrating multiple C++ subprojects with CMake + Conan 2, sccache remote cache, a Dockerized development environment, a GitHub Actions compiler matrix (gcc/clang/MSVC), sanitizers, and CPack .deb/.rpm packaging.

## Status

TBD - CI badges and project health indicators will be added in later steps.

## Supported platforms

| Platform | Environment |
| --- | --- |
| Linux | Ubuntu 22.04+, gcc >=11, clang >=15 |
| macOS | 14, AppleClang >=15 |
| Windows | Server 2022, MSVC 2022 |

## Architecture

TBD - This template follows a `projects/<name>/` monorepo model where the root CMake file orchestrates subprojects and each subproject can publish its own CPack components.

## Dependencies

| Library | Version | Purpose |
| --- | --- | --- |
| spdlog | 1.14.1 | logging (example subprojects) |
| GoogleTest | 1.14.0 | unit + integration tests |

## Build

From the repository root:

```bash
mkdir -p build && cd build
conan install .. --build=missing -pr:b=default -s build_type=Release
cd ..
cmake --preset conan-release
cmake --build build/Release
```

For CI-strict local verification, configure with clang and warnings-as-errors:

```bash
cmake --preset conan-release \
	-DPOLYCPP_WARNINGS_AS_ERRORS=ON \
	-DCMAKE_C_COMPILER=clang -DCMAKE_CXX_COMPILER=clang++
cmake --build build/Release
```

## Test

Run all discovered tests with CTest:

```bash
ctest --test-dir build/Release --output-on-failure
```

## Packaging

Linux packaging is enabled via `POLYCPP_ENABLE_PACKAGING` and produces
component-split packages. DEB names are `polycpp-hello-lib`,
`polycpp-hello-lib-dev`, and `polycpp-hello-app`; RPM uses the same names with
`polycpp-hello-lib-devel` for the development component.

Generate packages from the configured build tree:

```bash
cd build/Release
cpack -G "DEB;RPM"
```

## Docker dev environment

For a reproducible local environment, use [docs/docker-dev.md](docs/docker-dev.md).
The [Dockerfile.dev](Dockerfile.dev) image is based on Ubuntu 24.04 and ships
with CMake, Conan 2, sccache, clang-format, clang-tidy, cppcheck, rpmbuild,
and dpkg-dev preinstalled for CI-aligned local development.