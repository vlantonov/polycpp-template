# polycpp-template

polycpp-template is a reusable monorepo template for orchestrating multiple C++ subprojects with CMake + Conan 2, sccache remote cache, a Dockerized development environment, a GitHub Actions compiler matrix (gcc/clang/MSVC), sanitizers, and CPack .deb/.rpm packaging.

## Status

| Workflow | Badge |
| --- | --- |
| Ubuntu | ![ubuntu](https://github.com/vlantonov/polycpp-template/actions/workflows/ubuntu.yml/badge.svg) |
| macOS | ![macos](https://github.com/vlantonov/polycpp-template/actions/workflows/macos.yml/badge.svg) |
| Windows | ![windows](https://github.com/vlantonov/polycpp-template/actions/workflows/windows.yml/badge.svg) |
| Sanitizers | ![sanitizers](https://github.com/vlantonov/polycpp-template/actions/workflows/sanitizers.yml/badge.svg) |
| Static analysis | ![static-check](https://github.com/vlantonov/polycpp-template/actions/workflows/static_check.yml/badge.svg) |

3 unit + integration tests across 2 example subprojects; requires CMake >= 3.25, Conan >= 2.0, Python >= 3.10.

## Quickstart

```bash
git clone https://github.com/vlantonov/polycpp-template.git my-project
cd my-project
mkdir build && cd build
conan install .. --build=missing -pr:b=default -s build_type=Release
cd ..
cmake -S . -B build/Release -G Ninja \
	-DCMAKE_TOOLCHAIN_FILE=build/Release/generators/conan_toolchain.cmake \
	-DPOLYCPP_WARNINGS_AS_ERRORS=ON
cmake --build build/Release
ctest --test-dir build/Release --output-on-failure
```

Conan-generated preset names can vary by environment and generator (for
example, `conan-release` vs `conan-default`), so this repo prefers explicit
`-DCMAKE_TOOLCHAIN_FILE=...` configure commands in CI and docs.

To add your own subproject, create a new `projects/<name>/` directory with its
own target(s), tests, and install rules.
Follow the checklist in [docs/adding-subproject.md](docs/adding-subproject.md)
to wire it into the root orchestrator and CPack metadata consistently.

## Supported platforms

| Platform | Environment |
| --- | --- |
| Linux | Ubuntu 22.04+, gcc >=11, clang >=15 |
| macOS | 14, AppleClang >=15 |
| Windows | Server 2022, MSVC 2022 |

## Architecture

This template follows a `projects/<name>/` monorepo model where the root CMake
file orchestrates subprojects and each subproject can publish its own CPack
components.

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
cmake -S . -B build/Release -G Ninja \
	-DCMAKE_TOOLCHAIN_FILE=build/Release/generators/conan_toolchain.cmake
cmake --build build/Release
```

For CI-strict local verification, configure with clang and warnings-as-errors:

```bash
cmake -S . -B build/Release -G Ninja \
	-DCMAKE_TOOLCHAIN_FILE=build/Release/generators/conan_toolchain.cmake \
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

## Reusing this template

When turning this template into a project-specific monorepo, start with
[docs/adding-subproject.md](docs/adding-subproject.md) and keep naming
consistent across build, packaging, and CI metadata.
Rename the `polycpp` token to your project token in the root `CMakeLists.txt`
(`project(...)` call and `POLYCPP_*` cache-option prefix), update dependencies
in `conanfile.txt`, and refresh `.github/workflows/*` references such as badge
URLs and package naming used by CPack outputs.
Also update maintainer metadata in `cmake/Packaging.cmake`
(`CPACK_PACKAGE_VENDOR` and `CPACK_PACKAGE_CONTACT`) before your first release.

## License

Released under the [MIT License](LICENSE).